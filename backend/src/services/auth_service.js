const bcrypt = require("bcryptjs");
const Admin = require("../models/admin");
const { serializeDocument } = require("../utils/serialize_document");

async function login(email, password) {
  const admin = await Admin.findOne({ email: email.trim().toLowerCase() });
  if (!admin) {
    return null;
  }

  const matches = await bcrypt.compare(password, admin.passwordHash);
  if (!matches) {
    return null;
  }

  return serializeDocument(admin);
}

async function ensureAdmin({ email, password }) {
  if (!email || !password) {
    return null;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const admin = await Admin.findOneAndUpdate(
    { email: email.trim().toLowerCase() },
    {
      $set: {
        email: email.trim().toLowerCase(),
        passwordHash,
      },
    },
    {
      upsert: true,
      new: true,
      runValidators: true,
      setDefaultsOnInsert: true,
    },
  );

  return serializeDocument(admin);
}

module.exports = {
  ensureAdmin,
  login,
};
