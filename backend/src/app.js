const cors = require("cors");
const cookieParser = require("cookie-parser");
const express = require("express");
const { env } = require("./config/env");
const { errorHandler } = require("./middleware/error_handler");
const { createAuthRouter } = require("./routes/auth");
const { createContactRouter } = require("./routes/contact");
const { createHealthRouter } = require("./routes/health");
const { createProfileRouter } = require("./routes/profile");
const { createProjectsRouter } = require("./routes/projects");
const { createUploadsRouter } = require("./routes/uploads");
const authService = require("./services/auth_service");
const contactService = require("./services/contact_service");
const profileService = require("./services/profile_service");
const projectService = require("./services/project_service");
const uploadService = require("./services/upload_service");

function createCorsOptions() {
  const allowedOrigins = new Set(env.corsOrigins);

  return {
    credentials: true,
    origin(origin, callback) {
      if (!origin || allowedOrigins.size === 0 || allowedOrigins.has(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error(`Origin ${origin} is not allowed by CORS.`));
    },
  };
}

function createApp(overrides = {}) {
  const app = express();
  const services = {
    authService: overrides.authService || authService,
    contactService: overrides.contactService || contactService,
    profileService: overrides.profileService || profileService,
    projectService: overrides.projectService || projectService,
    uploadService: overrides.uploadService || uploadService,
  };

  app.use(cors(createCorsOptions()));
  app.use(express.json({ limit: "2mb" }));
  app.use(cookieParser());

  app.use("/api/health", createHealthRouter());
  app.use("/api/auth", createAuthRouter({ authService: services.authService }));
  app.use(
    "/api/profile",
    createProfileRouter({ profileService: services.profileService }),
  );
  app.use(
    "/api/projects",
    createProjectsRouter({ projectService: services.projectService }),
  );
  app.use(
    "/api/contact",
    createContactRouter({ contactService: services.contactService }),
  );
  app.use(
    "/api/uploads",
    createUploadsRouter({ uploadService: services.uploadService }),
  );

  app.use(errorHandler);

  return app;
}

module.exports = {
  createApp,
};
