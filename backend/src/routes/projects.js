const express = require("express");
const { requireAuth } = require("../middleware/auth");

function createProjectsRouter({ projectService }) {
  const router = express.Router();

  router.get("/", async (_req, res, next) => {
    try {
      const projects = await projectService.listPublicProjects();
      res.json({ projects });
    } catch (error) {
      next(error);
    }
  });

  router.post("/", requireAuth, async (req, res, next) => {
    try {
      const project = await projectService.createProject(req.body || {});
      res.status(201).json({ project });
    } catch (error) {
      next(error);
    }
  });

  return router;
}

module.exports = {
  createProjectsRouter,
};
