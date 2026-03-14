const express = require("express");

function createContactRouter({ contactService }) {
  const router = express.Router();

  router.post("/", async (req, res, next) => {
    try {
      const message = await contactService.createContactMessage(req.body || {});
      res.status(201).json({ message });
    } catch (error) {
      next(error);
    }
  });

  return router;
}

module.exports = {
  createContactRouter,
};
