const mongoose = require("mongoose");
const { env, requireEnv } = require("./env");

let hasConnected = false;

async function connectToDatabase() {
  if (hasConnected) {
    return mongoose.connection;
  }

  const uri = requireEnv("MONGODB_URI");
  await mongoose.connect(uri, {
    dbName: env.mongoDbName,
  });
  hasConnected = true;
  return mongoose.connection;
}

async function disconnectFromDatabase() {
  if (!hasConnected) {
    return;
  }
  await mongoose.disconnect();
  hasConnected = false;
}

module.exports = {
  connectToDatabase,
  disconnectFromDatabase,
};
