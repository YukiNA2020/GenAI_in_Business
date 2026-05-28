const app = require('../src/app');
const { closeDb } = require('../src/db/connection');

function assert(condition, message, detail) {
  if (!condition) {
    throw new Error(detail ? `${message}: ${detail}` : message);
  }
  console.log(`  PASS: ${message}`);
}

function listen() {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, '127.0.0.1', () => resolve(server));
    server.on('error', reject);
  });
}

async function getJson(baseUrl, path) {
  const response = await fetch(`${baseUrl}${path}`);
  const body = await response.json();
  return { status: response.status, body };
}

async function main() {
  console.log('\n=== ISSUE-03 rooms month/order regression ===\n');
  const server = await listen();
  const baseUrl = `http://127.0.0.1:${server.address().port}`;

  try {
    const roomsResponse = await getJson(baseUrl, '/api/rooms');
    assert(roomsResponse.status === 200, 'GET /api/rooms returns 200');
    assert(roomsResponse.body.success === true, 'GET /api/rooms succeeds');

    const rooms = roomsResponse.body.data || [];
    const months = rooms.map((room) => room.month);
    const labels = rooms.map((room) => room.label);
    assert(
      JSON.stringify(months) === JSON.stringify(['2026-05', '2026-06', '2026-07']),
      'rooms use May/June/July in display order',
      JSON.stringify(months),
    );
    assert(
      JSON.stringify(labels) === JSON.stringify(['May Room', 'June Room', 'July Room']),
      'rooms use matching labels',
      JSON.stringify(labels),
    );

    for (const room of rooms) {
      const detailResponse = await getJson(baseUrl, `/api/rooms/${room.id}`);
      assert(
        detailResponse.status === 200 && detailResponse.body.success === true,
        `GET /api/rooms/${room.id} succeeds`,
      );
      assert(
        Array.isArray(detailResponse.body.data.collections),
        `room ${room.id} detail includes collections array`,
      );
    }
  } finally {
    await new Promise((resolve) => server.close(resolve));
    closeDb();
  }

  console.log('\nISSUE-03 regression passed.\n');
}

main().catch((error) => {
  console.error(error.message || error);
  closeDb();
  process.exit(1);
});
