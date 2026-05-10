// ✅ Application Insights (alleen als env aanwezig is)

console.log("ENV:", process.env.APPLICATIONINSIGHTS_CONNECTION_STRING);
console.log("🚨 THIS IS THE NEW CODE 13🚨");
const appInsights = require('applicationinsights');

appInsights
  .setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
  .setAutoCollectRequests(true)
  .setAutoCollectDependencies(true)
  .setAutoCollectExceptions(true)
  .setAutoCollectPerformance(true)
  .setAutoCollectConsole(true)
  .setSendLiveMetrics(true)
  .setDistributedTracingMode(appInsights.DistributedTracingModes.AI)
  .start();

appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = 'order-service';  

setInterval(() => {
  appInsights.defaultClient.flush();
}, 5000);

// 🔥 FORCE test (belangrijk!)
const client = appInsights.defaultClient;
// 🔥 TEST 1
client.trackTrace({ message: "🔥 TRACE TEST 🔥" });

// 🔥 TEST 2
client.trackEvent({ name: "APP START EVENT" });

// 🔥 TEST 3
client.trackException({ exception: new Error("TEST ERROR") });

const express = require('express');
const { connectProducer, sendOrderEvent } = require('../kafka/producer');
const { createOrdersTable, saveOrder, getOrderStatus, pool } = require('./db');

const app = express();
app.use(express.json());

// 📦 Create order
app.post('/orders', async (req, res) => {
  try {
    const order = {
      orderId: Date.now(),
      customer: req.body.customer,
      item: req.body.item,
      location: {
        lat: req.body.lat,
        lng: req.body.lng
      },
      status: 'pending'
    };

    console.log('📦 Received order:', order);

    await saveOrder(order);
    await sendOrderEvent(order);

    res.status(201).json({
      message: 'Order received',
      order
    });

  } catch (err) {
    console.error('❌ Error processing order:', err.message);
    res.status(500).json({ error: 'Failed to process order' });
  }
});

// 🔍 Get order status
app.get('/orders/:orderId/status', async (req, res) => {
  try {
    const order = await getOrderStatus(req.params.orderId);

    if (order) {
      res.json({
        orderId: req.params.orderId,
        status: order
      });
    } else {
      res.status(404).json({ error: 'Order not found' });
    }

  } catch (err) {
    console.error('❌ Error fetching order status:', err.message);
    res.status(500).json({ error: 'Failed to fetch order status' });
  }
});

// ✏️ Update order status
app.patch('/orders/:orderId/status', async (req, res) => {
  try {
    await pool.query(
      `
      UPDATE public.orders 
      SET status = $1, driver_name = $2, updated_at = NOW() 
      WHERE order_id = $3
      `,
      [req.body.status, req.body.driverName, req.params.orderId]
    );

    res.json({ message: 'Order status updated' });

  } catch (err) {
    console.error('❌ Error updating order status:', err.message);
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

// ❤️ Health check (belangrijk voor Azure)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'Order service is healthy' });
});

// 🚀 Start server (correct voor Azure!)
async function startServer() {
  try {
    await createOrdersTable();
    console.log('✅ Orders table ready');

    await connectProducer();
    console.log('✅ Connected to Event Hubs');

    const port = process.env.PORT || 3000;

    app.listen(port, () => {
      console.log(`🚀 Order service running on port ${port}`);
    });

  } catch (err) {
    console.error('❌ Failed to start server:', err.message);
    process.exit(1);
  }
}

startServer();