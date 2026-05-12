if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}
const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     5432,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl:      process.env.DB_HOST.includes('azure.com') 
            ? { rejectUnauthorized: false }  // Azure → SSL aan
            : false                           // Lokaal → SSL uit
});

async function createTable() {
  try {
    await pool.query('CREATE SCHEMA IF NOT EXISTS public');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS public.driver_locations (
        id          SERIAL PRIMARY KEY,
        driver_id   INTEGER NOT NULL UNIQUE,
        driver_name VARCHAR(100),
        lat         DECIMAL(10, 8),
        lng         DECIMAL(11, 8),
        updated_at  TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✅ Table ready!');
  } catch (err) {
    console.error('❌ Database error:', err.message);
    throw err;
  }
}
async function saveDriverLocation(driverId, driverName, lat, lng) {
  await pool.query(`
    INSERT INTO public.driver_locations (driver_id, driver_name, lat, lng)
    VALUES ($1, $2, $3, $4)
    ON CONFLICT (driver_id) DO UPDATE
    SET lat = $3, lng = $4, updated_at = NOW()
  `, [driverId, driverName, lat, lng]);
  console.log(`📍 Updated location for ${driverName} (ID: ${driverId})`);
}

async function getAllDriverLocations() {
  const result = await pool.query(
    'SELECT * FROM public.driver_locations ORDER BY updated_at DESC'
  );
  return result.rows;
}

module.exports = { createTable, saveDriverLocation, getAllDriverLocations };