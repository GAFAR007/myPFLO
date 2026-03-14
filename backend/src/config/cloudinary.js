const { v2: cloudinary } = require("cloudinary");
const { env, requireEnv } = require("./env");

let isConfigured = false;

function configureCloudinary() {
  if (isConfigured) {
    return cloudinary;
  }

  cloudinary.config({
    cloud_name: requireEnv("CLOUDINARY_CLOUD_NAME"),
    api_key: requireEnv("CLOUDINARY_API_KEY"),
    api_secret: requireEnv("CLOUDINARY_API_SECRET"),
    secure: true,
  });
  isConfigured = true;
  return cloudinary;
}

async function uploadBuffer({
  buffer,
  folder,
  publicId,
  resourceType = "image",
  filename,
}) {
  configureCloudinary();

  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder,
        public_id: publicId,
        resource_type: resourceType,
        filename_override: filename,
        use_filename: Boolean(filename),
        unique_filename: false,
      },
      (error, result) => {
        if (error) {
          reject(error);
          return;
        }
        resolve(result);
      },
    );

    stream.end(buffer);
  });
}

module.exports = {
  configureCloudinary,
  env,
  uploadBuffer,
};
