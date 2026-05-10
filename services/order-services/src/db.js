// ✅ alleen in development
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
  ssl:      process.env.DB_HOST?.includes('azure.com')
    ? { rejectUnauthorized: false }
    : false
});

async function createOrdersTable() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS public.orders (
        id          SERIAL PRIMARY KEY,
        order_id    BIGINT NOT NULL UNIQUE,
        customer    VARCHAR(100),
        item        VARCHAR(100),
        lat         DECIMAL(10, 8),
        lng         DECIMAL(11, 8),
        status      VARCHAR(50) DEFAULT 'pending',
        driver_name VARCHAR(100),
        created_at  TIMESTAMP DEFAULT NOW(),
        updated_at  TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✅ Orders table ready!');
  } catch (err) {
    console.error('❌ Database error', err.message);
    throw err;
  }
}

async function saveOrder(order) {
  await pool.query(`
    INSERT INTO public.orders (order_id, customer, item, lat, lng, status)
    VALUES ($1, $2, $3, $4, $5, 'pending')
  `, [order.orderId, order.customer, order.item, order.location?.lat, order.location?.lng]);
  console.log(`💾 Order saved: ${order.orderId}`);
}

async function getOrderStatus(orderId) {
  const res = await pool.query(`
    SELECT * FROM public.orders WHERE order_id = $1
  `, [orderId]);
  return res.rows[0] ? res.rows[0] : null;
}

async function updateOrderStatus(orderId, status, driverName) {
  await pool.query(`
    UPDATE public.orders 
    SET status = $1, driver_name = $2, updated_at = NOW() 
    WHERE order_id = $3
  `, [status, driverName, orderId]);
  console.log(`🔄 Order ${orderId} updated to ${status} by ${driverName}`);
}

module.exports = {
  createOrdersTable,
  saveOrder,
  getOrderStatus,
  updateOrderStatus,
  pool
};