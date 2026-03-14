const mongoose = require("mongoose");

const projectSchema = new mongoose.Schema(
  {
    legacySupabaseId: {
      type: String,
      default: null,
      sparse: true,
      unique: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    subtitle: {
      type: String,
      default: null,
    },
    description: {
      type: String,
      default: null,
    },
    url: {
      type: String,
      default: null,
    },
    tags: {
      type: [String],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    sortOrder: {
      type: Number,
      default: 0,
    },
    legacyCreatedAt: Date,
    legacyUpdatedAt: Date,
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.models.Project || mongoose.model("Project", projectSchema);
