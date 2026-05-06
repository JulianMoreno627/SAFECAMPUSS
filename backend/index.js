require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { Pool } = require('pg');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

// Configuración de la base de datos (Render)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Inicialización de columnas faltantes para nuevas funciones (Migración automática)
(async () => {
  try {
    await pool.query('ALTER TABLE profiles ADD COLUMN IF NOT EXISTS foto_url TEXT');
    await pool.query('ALTER TABLE reportes ADD COLUMN IF NOT EXISTS foto_url TEXT');
    await pool.query('ALTER TABLE reportes ADD COLUMN IF NOT EXISTS testigos INTEGER DEFAULT 0');
    // Migrar testigos de TEXT a INTEGER si el tipo actual es text
    await pool.query(`
      DO $$ BEGIN
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name='reportes' AND column_name='testigos' AND data_type='text'
        ) THEN
          ALTER TABLE reportes ALTER COLUMN testigos TYPE INTEGER
          USING COALESCE(NULLIF(testigos, '')::INTEGER, 0);
        END IF;
      END $$;
    `);

    // Crear tabla de categorías si no existe
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categorias_incidente (
        id SERIAL PRIMARY KEY,
        nombre TEXT UNIQUE NOT NULL,
        icono TEXT,
        color TEXT
      )
    `);

    // Poblar categorías iniciales
    const cats = ['Robo', 'Acoso', 'Pelea', 'Vandalismo', 'Accidente', 'Persona sospechosa', 'Iluminación', 'Otro'];
    for (const cat of cats) {
      await pool.query('INSERT INTO categorias_incidente (nombre) VALUES ($1) ON CONFLICT DO NOTHING', [cat]);
    }

    console.log('Migración de DB completada.');
  } catch (e) {
    console.error('Error en la migración de DB:', e);
  }
})();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// --- AUTENTICACIÓN ---

// Registro de Usuario
app.post('/api/auth/register', async (req, res) => {
  const { email, password, nombre, apellido, telefono } = req.body;

  try {
    // Verificar si ya existe
    const userExist = await pool.query('SELECT * FROM profiles WHERE email = $1', [email]);
    if (userExist.rows.length > 0) {
      return res.status(400).json({ error: 'El correo ya está registrado' });
    }

    // Encriptar contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insertar usuario
    const query = `
      INSERT INTO profiles (email, password, nombre, apellido, telefono)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, email, nombre, apellido, foto_url;
    `;
    const result = await pool.query(query, [email, hashedPassword, nombre, apellido, telefono]);
    
    const token = jwt.sign({ id: result.rows[0].id }, JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({ user: result.rows[0], token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
});

// Inicio de Sesión
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM profiles WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Usuario no encontrado' });
    }

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(400).json({ error: 'Contraseña incorrecta' });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ user: { id: user.id, email: user.email, nombre: user.nombre, apellido: user.apellido, foto_url: user.foto_url }, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// Inicio de Sesión con Google
app.post('/api/auth/google', async (req, res) => {
  const { email, nombre, apellido } = req.body;

  try {
    // Buscar si el usuario ya existe
    let result = await pool.query('SELECT * FROM profiles WHERE email = $1', [email]);
    let user;

    if (result.rows.length === 0) {
      // Crear usuario nuevo (sin password para Google auth)
      const query = `
        INSERT INTO profiles (email, password, nombre, apellido)
        VALUES ($1, $2, $3, $4)
        RETURNING id, email, nombre, apellido, foto_url;
      `;
      // Usamos un password dummy o simplemente lo dejamos como 'google_auth'
      result = await pool.query(query, [email, 'google_auth_placeholder', nombre, apellido]);
      user = result.rows[0];
    } else {
      user = result.rows[0];
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ 
      user: { id: user.id, email: user.email, nombre: user.nombre, apellido: user.apellido, foto_url: user.foto_url }, 
      token 
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en autenticación de Google' });
  }
});

// Actualizar foto de perfil
app.put('/api/perfil/foto', async (req, res) => {
  const { user_id, foto_url } = req.body;
  try {
    const query = `
      UPDATE profiles 
      SET foto_url = $1 
      WHERE id = $2 
      RETURNING id, email, nombre, apellido, foto_url;
    `;
    const result = await pool.query(query, [foto_url, user_id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar foto de perfil' });
  }
});

// --- REPORTES ---

// Endpoint para obtener reportes cercanos (Uso de PostGIS)
app.get('/api/reportes/cercanos', async (req, res) => {
  const { lat, lng, radio = 5000, mapa } = req.query; // radio en metros (default 5km)

  try {
    // Si mapa es 'true', ignoramos los reportes de más de 3 días
    const timeFilter = mapa === 'true' ? "AND r.created_at >= NOW() - INTERVAL '3 days'" : "";
    
    const query = `
      SELECT r.id, r.tipo, r.descripcion, r.nivel_urgencia, r.foto_url, r.created_at, r.user_id,
             ST_X(r.ubicacion::geometry) as lng, 
             ST_Y(r.ubicacion::geometry) as lat,
             ST_Distance(r.ubicacion, ST_SetSRID(ST_MakePoint($1, $2), 4326)) as distancia,
             p.nombre as usuario_nombre,
             p.apellido as usuario_apellido,
             p.foto_url as usuario_foto_url
      FROM reportes r
      LEFT JOIN profiles p ON r.user_id = p.id
      WHERE ST_DWithin(r.ubicacion, ST_SetSRID(ST_MakePoint($1, $2), 4326), $3)
      ${timeFilter}
      ORDER BY r.created_at DESC;
    `;
    const result = await pool.query(query, [lng, lat, radio]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener reportes' });
  }
});

// Endpoint para obtener reportes del usuario
app.get('/api/reportes/usuario/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const query = `
      SELECT r.id, r.tipo, r.descripcion, r.nivel_urgencia, r.foto_url, r.created_at, r.user_id,
             ST_X(r.ubicacion::geometry) as lng, 
             ST_Y(r.ubicacion::geometry) as lat,
             p.nombre as usuario_nombre,
             p.apellido as usuario_apellido,
             p.foto_url as usuario_foto_url
      FROM reportes r
      LEFT JOIN profiles p ON r.user_id = p.id
      WHERE r.user_id = $1
      ORDER BY r.created_at DESC;
    `;
    const result = await pool.query(query, [userId]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener reportes del usuario' });
  }
});

// Endpoint para crear un reporte (Insertar con PostGIS)
app.post('/api/reportes', async (req, res) => {
  const { tipo, descripcion, nivel_urgencia, lat, lng, user_id, foto_url, testigos } = req.body;

  // UUID vacío o inválido → null (evita error de cast en PostgreSQL)
  const userId = (user_id && user_id.trim() !== '') ? user_id : null;
  const testigosVal = parseInt(testigos) || 0;

  try {
    const query = `
      INSERT INTO reportes (tipo, descripcion, nivel_urgencia, ubicacion, user_id, foto_url, testigos)
      VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), $6, $7, $8)
      RETURNING *, ST_X(ubicacion::geometry) as lng, ST_Y(ubicacion::geometry) as lat;
    `;
    const result = await pool.query(query, [tipo, descripcion, nivel_urgencia, lng, lat, userId, foto_url, testigosVal]);

    // Emitir evento en tiempo real a los clientes conectados
    io.emit('nuevo_reporte', result.rows[0]);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error al crear reporte:', err.message);
    res.status(500).json({ error: 'Error al crear el reporte', detail: err.message });
  }
});

// Endpoint para borrar todos los reportes (EXPERIMENTACIÓN)
app.delete('/api/reportes', async (req, res) => {
  try {
    await pool.query('DELETE FROM reportes');
    res.json({ message: 'Todos los reportes han sido eliminados' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al eliminar reportes' });
  }
});

// --- CATEGORÍAS ---

app.get('/api/categorias', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categorias_incidente ORDER BY nombre ASC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

app.post('/api/categorias', async (req, res) => {
  const { nombre, icono, color } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO categorias_incidente (nombre, icono, color) VALUES ($1, $2, $3) RETURNING *',
      [nombre, icono, color]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear categoría' });
  }
});

// --- EMERGENCIAS (SOS) ---
app.post('/api/emergencias', async (req, res) => {
  const { user_id, lat, lng } = req.body;
  try {
    const query = `
      INSERT INTO emergencias (user_id, ubicacion)
      VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))
      RETURNING *;
    `;
    const result = await pool.query(query, [user_id, lng, lat]);
    io.emit('nueva_emergencia', result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar emergencia' });
  }
});

// --- CONTACTOS DE EMERGENCIA ---
app.get('/api/contactos/:user_id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM contactos_emergencia WHERE user_id = $1', [req.params.user_id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener contactos' });
  }
});

app.post('/api/contactos', async (req, res) => {
  const { user_id, nombre, telefono, relacion } = req.body;
  try {
    const query = `
      INSERT INTO contactos_emergencia (user_id, nombre, telefono, relacion)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const result = await pool.query(query, [user_id, nombre, telefono, relacion]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear contacto' });
  }
});

// --- RUTAS GUARDADAS ---
app.get('/api/rutas/:user_id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM rutas_guardadas WHERE user_id = $1 ORDER BY created_at DESC', [req.params.user_id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener rutas' });
  }
});

app.post('/api/rutas', async (req, res) => {
  const { user_id, nombre, origen_lat, origen_lng, destino_lat, destino_lng, score_seguridad } = req.body;
  try {
    const query = `
      INSERT INTO rutas_guardadas (user_id, nombre, origen_lat, origen_lng, destino_lat, destino_lng, score_seguridad)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const result = await pool.query(query, [user_id, nombre, origen_lat, origen_lng, destino_lat, destino_lng, score_seguridad]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar ruta' });
  }
});

io.on('connection', (socket) => {
  console.log('Un cliente se ha conectado:', socket.id);
  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});

server.listen(port, () => {
  console.log(`Servidor corriendo en el puerto ${port}`);
});
