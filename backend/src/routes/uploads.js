const express = require("express");
const multer = require("multer");
const { requireAuth } = require("../middleware/auth");

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
  },
});

function ensureFile(req) {
  if (!req.file) {
    const error = new Error("A file upload is required.");
    error.statusCode = 400;
    throw error;
  }
}

function createUploadsRouter({ uploadService }) {
  const router = express.Router();

  router.post(
    "/avatar",
    requireAuth,
    upload.single("file"),
    async (req, res, next) => {
      try {
        ensureFile(req);
        const result = await uploadService.uploadFile({
          buffer: req.file.buffer,
          folder: "portfolio/avatars",
          originalName: req.file.originalname,
          resourceType: "image",
        });
        res.status(201).json(result);
      } catch (error) {
        next(error);
      }
    },
  );

  router.post("/cv", requireAuth, upload.single("file"), async (req, res, next) => {
    try {
      ensureFile(req);
      const result = await uploadService.uploadFile({
        buffer: req.file.buffer,
        folder: "portfolio/cvs",
        originalName: req.file.originalname,
        resourceType: "raw",
      });
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  });

  return router;
}

module.exports = {
  createUploadsRouter,
};
