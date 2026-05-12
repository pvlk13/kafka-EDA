async function connectConsumer() {
  try {
    await consumer.connect();

    await consumer.subscribe({
      topic: 'order-topic',
      fromBeginning: false
    });

    await consumer.run({
      eachMessage: async ({ message }) => {
        try {
          const order = JSON.parse(message.value.toString());

          console.log('🚗 New order received:', order);

          if (order.lat == null || order.lng == null) {
            console.error('❌ Invalid order location');
            return;
          }

          const { driver, distance } = findNearestDriver(
            order.lat,
            order.lng
          );

          if (!driver) {
            console.error('❌ No driver found');
            return;
          }

          console.log(
            `🏆 Nearest driver: ${driver.name} (distance: ${distance.toFixed(4)})`
          );

          await saveDriverLocation(
            driver.id,
            driver.name,
            driver.lat,
            driver.lng
          );

          console.log('💾 Driver location saved to database!');

          await updateOrderStatus(
            order.orderId,
            'accepted',
            driver.name
          );

        } catch (err) {
          console.error('❌ Error processing message:', err.message);
        }
      }
    });

    console.log('✅ Driver-service listening on order-topic');

  } catch (err) {
    console.error('❌ Consumer error:', err.message);
    throw err;
  }
}