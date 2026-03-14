const express = require("express");
const { requireAuth } = require("../middleware/auth");

function createProfileRouter({ profileService }) {
  const router = express.Router();

  router.get("/", async (_req, res, next) => {
    try {
      const profile = await profileService.getPublicProfile();
      res.json({ profile });
    } catch (error) {
      next(error);
    }
  });

  router.put("/", requireAuth, async (req, res, next) => {
    try {
      const profile = await profileService.upsertPublicProfile(req.body || {});
      res.json({ profile });
    } catch (error) {
      next(error);
    }
  });

  return router;
}

module.exports = {
  createProfileRouter,
};
