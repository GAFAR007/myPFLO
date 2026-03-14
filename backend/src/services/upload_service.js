const path = require("path");
const { uploadBuffer } = require("../config/cloudinary");

function toPublicId(originalName) {
  const extension = path.extname(originalName);
  const stem = path.basename(originalName, extension);
  return `${stem.replace(/[^a-zA-Z0-9_-]/g, "-")}-${Date.now()}`;
}

async function uploadFile({ buffer, folder, originalName, resourceType }) {
  const result = await uploadBuffer({
    buffer,
    folder,
    publicId: toPublicId(originalName),
    resourceType,
    filename: originalName,
  });

  return {
    url: result.secure_url,
    publicId: result.public_id,
  };
}

module.exports = {
  uploadFile,
};
