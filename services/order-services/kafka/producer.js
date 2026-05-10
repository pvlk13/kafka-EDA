if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'order-service',
  brokers: ['vijaya-eh12-namespace.servicebus.windows.net:9093'],
  ssl: true,
  sasl: {
    mechanism: 'plain',
    username: '$ConnectionString',
    password: process.env.EVENT_HUB_CONNECTION_STRING
  }
});

const producer = kafka.producer();

async function connectProducer() {
  await producer.connect();
  console.log('Connected to Event Hubs');
}

async function sendOrderEvent(order) {
  await producer.send({
    topic: 'order-topic',
    messages: [
      { value: JSON.stringify(order) }
    ]
  });
  console.log('Event sent:', order);
}

module.exports = { connectProducer, sendOrderEvent };