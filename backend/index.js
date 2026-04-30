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

io.on('connection', (socket) => {
  console.log('Un cliente se ha conectado:', socket.id);
  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});

server.listen(port, () => {
  console.log(`Servidor corriendo en el puerto ${port}`);
});
