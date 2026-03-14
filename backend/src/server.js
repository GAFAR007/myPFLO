const { createApp } = require("./app");
const { connectToDatabase } = require("./config/database");
const { env, requireEnv } = require("./config/env");
const { ensureAdmin } = require("./services/auth_service");

async function start() {
  requireEnv("MONGODB_URI");
  requireEnv("JWT_SECRET");

  await connectToDatabase();
  await ensureAdmin({
    email: env.adminEmail,
    password: env.adminPassword,
  });

  const app = createApp();
  app.listen(env.port, () => {
    console.log(`Backend listening on port ${env.port}`);
  });
}

start().catch((error) => {
  console.error("Failed to start backend");
  console.error(error);
  process.exit(1);
});
