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
  console.log(`Order ${orderId} updated to ${status} by ${driverName}`);
}