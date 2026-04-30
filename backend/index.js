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

app.use(cors());
app.use(express.json());

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

    // Insertar usuario (Nota: necesitamos una columna password en la tabla profiles)
    // Vamos a añadirla al schema si no existe
    const query = `
      INSERT INTO profiles (email, password, nombre, apellido, telefono)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, email, nombre;
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
    res.json({ user: { id: user.id, email: user.email, nombre: user.nombre }, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// --- REPORTES ---

// Endpoint para obtener reportes cercanos (Uso de PostGIS)
app.get('/api/reportes/cercanos', async (req, res) => {
  const { lat, lng, radio = 5000 } = req.query; // radio en metros (default 5km)

  try {
    const query = `
      SELECT id, tipo, descripcion, nivel_urgencia, 
             ST_X(ubicacion::geometry) as lng, 
             ST_Y(ubicacion::geometry) as lat,
             ST_Distance(ubicacion, ST_SetSRID(ST_MakePoint($1, $2), 4326)) as distancia
      FROM reportes
      WHERE ST_DWithin(ubicacion, ST_SetSRID(ST_MakePoint($1, $2), 4326), $3)
      ORDER BY distancia ASC;
    `;
    const result = await pool.query(query, [lng, lat, radio]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener reportes' });
  }
});

// Endpoint para crear un reporte (Insertar con PostGIS)
app.post('/api/reportes', async (req, res) => {
  const { tipo, descripcion, nivel_urgencia, lat, lng, user_id } = req.body;

  try {
    const query = `
      INSERT INTO reportes (tipo, descripcion, nivel_urgencia, ubicacion, user_id)
      VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), $6)
      RETURNING *;
    `;
    const result = await pool.query(query, [tipo, descripcion, nivel_urgencia, lng, lat, user_id]);
    
    // Emitir evento en tiempo real a los clientes conectados
    io.emit('nuevo_reporte', result.rows[0]);
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear el reporte' });
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
