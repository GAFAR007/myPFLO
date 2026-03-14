const express = require("express");
const {
  attachAdminFromCookie,
  clearAuthCookie,
  createAuthToken,
  setAuthCookie,
} = require("../middleware/auth");

function createAuthRouter({ authService }) {
  const router = express.Router();

  router.post("/login", async (req, res, next) => {
    try {
      const email = String(req.body?.email || "").trim();
      const password = String(req.body?.password || "");

      if (!email || !password) {
        res.status(400).json({ error: "Email and password are required." });
        return;
      }

      const admin = await authService.login(email, password);
      if (!admin) {
        res.status(401).json({ error: "Invalid email or password." });
        return;
      }

      const token = createAuthToken({
        id: admin.id,
        email: admin.email,
      });
      setAuthCookie(res, token);
      res.json({ admin: { id: admin.id, email: admin.email } });
    } catch (error) {
      next(error);
    }
  });

  router.post("/logout", (_req, res) => {
    clearAuthCookie(res);
    res.status(204).send();
  });

  router.get("/me", (req, res) => {
    const admin = attachAdminFromCookie(req);
    if (!admin) {
      res.status(401).json({ error: "Not authenticated." });
      return;
    }

    res.json({
      admin: {
        id: admin.id,
        email: admin.email,
      },
    });
  });

  return router;
}

module.exports = {
  createAuthRouter,
};
