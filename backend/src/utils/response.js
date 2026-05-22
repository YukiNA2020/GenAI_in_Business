function success(res, data, message = '', statusCode = 200) {
  const body = { success: true, data };
  if (message) body.message = message;
  return res.status(statusCode).json(body);
}

function created(res, data, message = 'Created') {
  return success(res, data, message, 201);
}

function error(res, code, message, statusCode = 400) {
  return res.status(statusCode).json({
    success: false,
    error: { code, message },
  });
}

module.exports = { success, created, error };
