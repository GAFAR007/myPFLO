const { connectToDatabase, disconnectFromDatabase } = require("../config/database");
const { env, requireEnv } = require("../config/env");
const { ensureAdmin } = require("../services/auth_service");

async function run() {
  requireEnv("MONGODB_URI");
  requireEnv("ADMIN_EMAIL");
  requireEnv("ADMIN_PASSWORD");

  await connectToDatabase();
  const admin = await ensureAdmin({
    email: env.adminEmail,
    password: env.adminPassword,
  });

  console.log(`Admin ready: ${admin.email}`);
}

run()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectFromDatabase();
  });
