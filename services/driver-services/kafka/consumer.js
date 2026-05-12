await consumer.run({
  eachMessage: async ({ message }) => {
    try {
      const order = JSON.parse(message.value.toString());

      console.log('🚗 New order received:', order);

      // ✅ Controleer locatie
      if (order.lat == null || order.lng == null) {
        console.error('❌ Invalid order location');
        return;
      }

      // ✅ Zoek dichtstbijzijnde driver
      const { driver, distance } = findNearestDriver(
        order.lat,
        order.lng
      );

      // ✅ Extra safety check
      if (!driver) {
        console.error('❌ No driver found');
        return;
      }

      console.log(
        `🏆 Nearest driver: ${driver.name} (distance: ${distance.toFixed(4)})`
      );

      // ✅ Driver locatie opslaan
      await saveDriverLocation(
        driver.id,
        driver.name,
        driver.lat,
        driver.lng
      );

      console.log('💾 Driver location saved to database!');

      // ✅ Order status updaten
      await updateOrderStatus(
        order.orderId,
        'accepted',
        driver.name
      );

      console.log(`✅ Order ${order.orderId} accepted by ${driver.name}`);

    } catch (err) {
      console.error('❌ Error processing Kafka message:', err.message);
    }
  }
});