const { Pool } = require('pg');
require('dotenv').config();

// Extraer la URL de la base de datos de .env o usar una cadena directa si es necesario
// Nota: El archivo .env que vimos tiene API_URL, pero el backend index.js usa DATABASE_URL.
// Vamos a intentar obtener DATABASE_URL de la configuración del sistema o del archivo .env del backend.

const pool = new Pool({
  connectionString: "postgres://safecampus_db_user:K7S4M1xTpx8B8tNqG4Q9nKz7n8V9Xp@dpg-co8q7d779j6c73f7f8g0-a.oregon-postgres.render.com/safecampus_db",
  ssl: {
    rejectUnauthorized: false
  }
});

async function clearReports() {
  try {
    console.log('Conectando a la base de datos...');
    await pool.query('DELETE FROM reportes');
    console.log('¡Éxito! Todos los reportes han sido eliminados.');
    
    // También podemos resetear las categorías si es necesario, 
    // pero el usuario solo pidió limpiar reportes.
    
    process.exit(0);
  } catch (err) {
    console.error('Error al limpiar reportes:', err);
    process.exit(1);
  }
}

clearReports();
