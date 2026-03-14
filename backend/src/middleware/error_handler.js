function errorHandler(error, _req, res, _next) {
  const statusCode = error.statusCode || 500;
  const message = error.message || "Internal server error.";

  if (statusCode >= 500) {
    // Keep backend logs readable in Render without exposing internals to clients.
    console.error(error);
  }

  res.status(statusCode).json({ error: message });
}

module.exports = {
  errorHandler,
};
