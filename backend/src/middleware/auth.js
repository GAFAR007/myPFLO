const jwt = require("jsonwebtoken");
const { authCookieOptions, requireEnv } = require("../config/env");

const AUTH_COOKIE_NAME = "portfolio_admin_token";

function createAuthToken(payload) {
  return jwt.sign(payload, requireEnv("JWT_SECRET"), {
    expiresIn: "7d",
  });
}

function verifyAuthToken(token) {
  return jwt.verify(token, requireEnv("JWT_SECRET"));
}

function setAuthCookie(res, token) {
  res.cookie(AUTH_COOKIE_NAME, token, authCookieOptions());
}

function clearAuthCookie(res) {
  res.clearCookie(AUTH_COOKIE_NAME, authCookieOptions());
}

function requireAuth(req, res, next) {
  const token = req.cookies[AUTH_COOKIE_NAME];
  if (!token) {
    res.status(401).json({ error: "Authentication required." });
    return;
  }

  try {
    req.admin = verifyAuthToken(token);
    next();
  } catch (error) {
    clearAuthCookie(res);
    res.status(401).json({ error: "Session expired. Please sign in again." });
  }
}

function attachAdminFromCookie(req) {
  const token = req.cookies[AUTH_COOKIE_NAME];
  if (!token) {
    return null;
  }

  try {
    return verifyAuthToken(token);
  } catch (_) {
    return null;
  }
}

module.exports = {
  AUTH_COOKIE_NAME,
  attachAdminFromCookie,
  clearAuthCookie,
  createAuthToken,
  requireAuth,
  setAuthCookie,
};
