-- Habilitar la extensión PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabla de Perfiles (Migración desde Supabase)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL, -- Nueva columna para autenticación propia
    nombre TEXT,
    apellido TEXT,
    telefono TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Reportes de Incidentes con soporte Geoespacial
CREATE TABLE IF NOT EXISTS reportes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    tipo TEXT NOT NULL, -- 'Robo', 'Acoso', etc.
    descripcion TEXT,
    nivel_urgencia TEXT CHECK (nivel_urgencia IN ('bajo', 'medio', 'alto', 'critico')),
    -- Campo geoespacial: Punto (longitud, latitud) en SRID 4326 (WGS 84)
    ubicacion GEOMETRY(Point, 4326), 
    foto_url TEXT,
    testigos TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice espacial para búsquedas rápidas por cercanía
CREATE INDEX IF NOT EXISTS reportes_ubicacion_idx ON reportes USING GIST (ubicacion);

-- Ejemplo de inserción con PostGIS:
-- INSERT INTO reportes (tipo, descripcion, nivel_urgencia, ubicacion) 
-- VALUES ('Robo', 'Celular hurtado', 'alto', ST_SetSRID(ST_MakePoint(-77.2811, 1.2136), 4326));

-- Tabla de Emergencias (Registro de Activación SOS)
CREATE TABLE IF NOT EXISTS emergencias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    ubicacion GEOMETRY(Point, 4326),
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Tabla de Contactos de Emergencia
CREATE TABLE IF NOT EXISTS contactos_emergencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    nombre TEXT NOT NULL,
    telefono TEXT NOT NULL,
    relacion TEXT,
    notificar_sos BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Rutas Guardadas (Frecuentes o Favoritas)
CREATE TABLE IF NOT EXISTS rutas_guardadas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    nombre TEXT,
    origen_lat FLOAT,
    origen_lng FLOAT,
    destino_lat FLOAT,
    destino_lng FLOAT,
    score_seguridad INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
