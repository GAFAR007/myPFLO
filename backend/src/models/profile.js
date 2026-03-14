const mongoose = require("mongoose");

const profileSchema = new mongoose.Schema(
  {
    singletonKey: {
      type: String,
      default: "public",
      unique: true,
      index: true,
    },
    legacySupabaseId: {
      type: String,
      default: null,
    },
    fullName: String,
    title: String,
    email: String,
    tagline: String,
    aboutMd: String,
    phoneE164: String,
    phone: String,
    linkedin: String,
    cvUrl: String,
    github: String,
    twitter: String,
    website: String,
    location: String,
    avatarUrl: String,
    firstName: String,
    middleName: String,
    lastName: String,
    dateOfBirth: Date,
    legacyCreatedAt: Date,
    legacyUpdatedAt: Date,
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.models.Profile || mongoose.model("Profile", profileSchema);
