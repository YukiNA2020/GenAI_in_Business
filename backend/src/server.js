require('dotenv').config();
const app = require('./app');
const { migrateSeedImagePaths } = require('./db/migrate-seed-images');

const PORT = process.env.PORT || 3000;

migrateSeedImagePaths()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Collection Journey API running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Failed to migrate seed image paths:', err);
    process.exit(1);
  });
