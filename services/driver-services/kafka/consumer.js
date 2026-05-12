const { Kafka } = require('kafkajs');
const { saveDriverLocation } = require('../src/db');

const kafka = new Kafka({
  clientId: 'driver-service',
  brokers: ['vijaya-eh12-namespace.servicebus.windows.net:9093'],
  ssl: true,
  sasl: {
    mechanism: 'plain',
    username: '$ConnectionString',
    password: process.env.EVENT_HUB_CONNECTION_STRING
  }
});

const consumer = kafka.consumer({ groupId: 'driver-group' });

function findNearestDriver(orderLat, orderLng) {
  const drivers = [
    { id: 1, name: 'Driver Arun', lat: 51.9225, lng: 4.4792 },
    { id: 2, name: 'Driver Jagdesh', lat: 51.9100, lng: 4.4800 },
    { id: 3, name: 'Driver Saroja', lat: 51.9300, lng: 4.4700 }
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
  console.log(`🔄 Order ${orderId} updated to ${status} by ${driverName}`);
}

async function connectConsumer() {
  await consumer.connect();
  console.log('✅ Consumer connected to Event Hubs');

  await consumer.subscribe({ topic: 'order-topic', fromBeginning: false });

  await consumer.run({
    eachMessage: async ({ message }) => {
      const order = JSON.parse(message.value.toString());
      console.log('📦 Received order:', order);

      // ✅ null check voor location
      if (!order.location?.lat || !order.location?.lng) {
        console.log(`❌ Order ${order.orderId} heeft geen locatie, overgeslagen`);
        return;
      }

      const result = findNearestDriver(order.location.lat, order.location.lng);

      // ✅ null check voor driver
      if (!result.driver) {
        console.log(`❌ Geen driver gevonden voor order ${order.orderId}`);
        return;
      }

      const { driver } = result;
      console.log(`🚗 Nearest driver: ${driver.name}`);
      await updateOrderStatus(order.orderId, 'assigned', driver.name);
      await saveDriverLocation(driver.id, driver.name, driver.lat, driver.lng);
    }
  });
}

module.exports = { connectConsumer };