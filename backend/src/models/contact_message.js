const mongoose = require("mongoose");

const contactMessageSchema = new mongoose.Schema(
  {
    legacySupabaseId: {
      type: String,
      default: null,
      sparse: true,
      unique: true,
    },
    firstName: {
      type: String,
      required: true,
      trim: true,
    },
    lastName: {
      type: String,
      default: null,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
    },
    subject: {
      type: String,
      default: null,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    legacyCreatedAt: Date,
    legacyUpdatedAt: Date,
  },
  {
    timestamps: true,
  },
);

module.exports =
  mongoose.models.ContactMessage ||
  mongoose.model("ContactMessage", contactMessageSchema);
