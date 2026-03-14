const Profile = require("../models/profile");
const { serializeDocument } = require("../utils/serialize_document");
const { normalizeProfilePayload } = require("../utils/normalize_profile_payload");

async function getPublicProfile() {
  const profile = await Profile.findOne({ singletonKey: "public" });
  return serializeDocument(profile);
}

async function upsertPublicProfile(payload) {
  const normalized = normalizeProfilePayload(payload);
  const profile = await Profile.findOneAndUpdate(
    { singletonKey: "public" },
    {
      $set: normalized,
      $setOnInsert: { singletonKey: "public" },
    },
    {
      upsert: true,
      new: true,
      runValidators: true,
      setDefaultsOnInsert: true,
    },
  );

  return serializeDocument(profile);
}

module.exports = {
  getPublicProfile,
  upsertPublicProfile,
};
