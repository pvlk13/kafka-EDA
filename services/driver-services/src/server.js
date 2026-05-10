const appInsights = require('applicationinsights');
appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
  .setAutoCollectRequests(true)
  .setAutoCollectExceptions(true)
  .setAutoCollectDependencies(true)
  .setSendLiveMetrics(true)
  .start();

appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = 'driver-service';  
const express = require('express');
const { connectConsumer } = require('../kafka/consumer');
const { createTable, getAllDriverLocations } = require('./db');

const app = express();
app.use(express.json());

const drivers = [
  { id: 1, name: 'Driver Arun', lat: 51.9225, lng: 4.4792 },
  { id: 2, name: 'Driver Jagdesh',   lat: 51.9100, lng: 4.4800 },
  { id: 3, name: 'Driver Saroja',  lat: 51.9300, lng: 4.4700 }
];

function findNearestDriver(orderLat, orderLng) {
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

app.get('/health', (req, res) => {
  res.json({ status: 'driver-service running' });
});

app.get('/drivers', async(req, res) => {
  try {
    const locations = await getAllDriverLocations();
    res.json({ drivers: locations });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

async function startServer() {
  try {
    await createTable();  // ✅ Zorg dat de tabel klaar is voordat we consumer starten
    await connectConsumer();
    app.listen(3001, () => {
      console.log('✅ Driver service running on port 3001');
    });
  } catch (err) {
    console.error('❌ Failed to start:', err.message);
    process.exit(1);
  }
}
startServer();