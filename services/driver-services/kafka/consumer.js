const { Kafka } = require('kafkajs');
const { saveDriverLocation } = require('../src/db');
require('dotenv').config();

const kafka = new Kafka({
  clientId: 'driver-service',
  brokers: ['vijaya-eh12-namespace.servicebus.windows.net:9093'],
  ssl: true,
  sasl: {
    mechanism: 'plain',
    username: '$ConnectionString',
    password: process.env.EVENT_HUB_CONNECTION_STRING
  },
  connectionTimeout: 10000,
  requestTimeout: 30000,
  retry: { retries: 5 }
});

const consumer = kafka.consumer({ groupId: 'driver-group' });

function findNearestDriver(orderLat, orderLng) {
  const drivers = [
    { id: 1, name: 'Driver Arun', lat: 51.9225, lng: 4.4792 },
  { id: 2, name: 'Driver Jagdesh',   lat: 51.9100, lng: 4.4800 },
  { id: 3, name: 'Driver Saroja',  lat: 51.9300, lng: 4.4700 }
  ];

  return drivers.reduce((nearest, driver) => {
    const distance = Math.sqrt(
      Math.pow(driver.lat - orderLat, 2) +
      Math.pow(driver.lng - orderLng, 2)
    );
    return distance < nearest.distance
      ? { driver, distance }
      : nearest;
  }, { driver: null, distance: Infinity });
}

async function updateOrderStatus(orderId, status, driverName) {
  try {
    await fetch(`https://order-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/orders/${orderId}/status`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status, driverName })
    });
    console.log(`📝 Order ${orderId} status updated to: ${status}`);
  } catch (err) {
    console.error('❌ Failed to update order status:', err.message);
  }
}

async function connectConsumer() {
  try {
    await consumer.connect();
    await consumer.subscribe({ topic: 'order-topic', fromBeginning: false });

    await consumer.run({
  eachMessage: async ({ message }) => {
    const order = JSON.parse(message.value.toString());
    console.log('🚗 New order received:', order);

    if (order.location) {
      const { driver, distance } = findNearestDriver(
        order.location.lat,
        order.location.lng
      );
      console.log(`🏆 Nearest driver: ${driver.name} (distance: ${distance.toFixed(4)})`);

      // ✅ Sla driver locatie op
      await saveDriverLocation(driver.id, driver.name, driver.lat, driver.lng);
      console.log(`💾 Driver location saved to database!`);

      // ✅ Update order status ← dit ontbrak!
      await updateOrderStatus(order.orderId, 'accepted', driver.name);
    }
  }
});
    console.log('✅ Driver-service listening on order-topic');
  } catch (err) {
    console.error('❌ Consumer error:', err.message);
    throw err;
  }
}

module.exports = { connectConsumer };