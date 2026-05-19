function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const message = result.error.issues
        .map((i) => `${i.path.join('.')}: ${i.message}`)
        .join('; ');
      const fields = {};
      result.error.issues.forEach((i) => {
        fields[i.path.join('.')] = i.message;
      });
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message, fields },
      });
    }
    req.validatedBody = result.data;
    next();
  };
}

module.exports = { validate };
