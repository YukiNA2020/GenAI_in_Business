const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ success: true, message: 'Collection Journey API is running' });
});

// Route mounting
app.use('/api/collections', require('./routes/collections.routes'));
app.use('/api/categories', require('./routes/categories.routes'));
app.use('/api/users', require('./routes/users.routes'));
// 成员 E：AI 建议接口（阶段二任务 2–4）
app.use('/api/ai', require('./routes/ai.routes'));

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Route not found' } });
});

// Global error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'Internal server error' },
  });
});

module.exports = app;
