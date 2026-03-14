const test = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const { createApp } = require("../src/app");

process.env.JWT_SECRET = "test-secret";

function createServices() {
  let profile = null;
  const projects = [];
  const contacts = [];

  return {
    authService: {
      async login(email, password) {
        if (email === "admin@example.com" && password === "password123") {
          return { id: "admin-1", email };
        }
        return null;
      },
    },
    profileService: {
      async getPublicProfile() {
        return profile;
      },
      async upsertPublicProfile(payload) {
        profile = {
          id: "profile-1",
          ...profile,
          ...payload,
        };
        return profile;
      },
    },
    projectService: {
      async listPublicProjects() {
        return projects;
      },
      async createProject(payload) {
        const project = { id: `${projects.length + 1}`, ...payload };
        projects.push(project);
        return project;
      },
    },
    contactService: {
      async createContactMessage(payload) {
        const message = { id: `${contacts.length + 1}`, ...payload };
        contacts.push(message);
        return message;
      },
    },
    uploadService: {
      async uploadFile({ originalName, folder }) {
        return {
          url: `https://cdn.example.com/${folder}/${originalName}`,
          publicId: `${folder}/${originalName}`,
        };
      },
    },
  };
}

async function loginAndGetCookie(app) {
  const response = await request(app).post("/api/auth/login").send({
    email: "admin@example.com",
    password: "password123",
  });
  assert.equal(response.status, 200);
  return response.headers["set-cookie"];
}

test("admin login success and failure", async () => {
  const app = createApp(createServices());

  const success = await request(app).post("/api/auth/login").send({
    email: "admin@example.com",
    password: "password123",
  });
  assert.equal(success.status, 200);
  assert.equal(success.body.admin.email, "admin@example.com");

  const failure = await request(app).post("/api/auth/login").send({
    email: "admin@example.com",
    password: "wrong",
  });
  assert.equal(failure.status, 401);
});

test("profile read and update require auth for writes", async () => {
  const app = createApp(createServices());

  const initial = await request(app).get("/api/profile");
  assert.equal(initial.status, 200);
  assert.equal(initial.body.profile, null);

  const unauthorized = await request(app).put("/api/profile").send({
    fullName: "Guest",
  });
  assert.equal(unauthorized.status, 401);

  const cookie = await loginAndGetCookie(app);
  const updated = await request(app)
    .put("/api/profile")
    .set("Cookie", cookie)
    .send({
      fullName: "Razak Gafar",
      email: "razak@example.com",
    });
  assert.equal(updated.status, 200);
  assert.equal(updated.body.profile.fullName, "Razak Gafar");
});

test("projects list and creation", async () => {
  const app = createApp(createServices());
  const cookie = await loginAndGetCookie(app);

  const created = await request(app)
    .post("/api/projects")
    .set("Cookie", cookie)
    .send({
      title: "Portfolio",
      tags: ["flutter", "mongodb"],
    });
  assert.equal(created.status, 201);
  assert.equal(created.body.project.title, "Portfolio");

  const listed = await request(app).get("/api/projects");
  assert.equal(listed.status, 200);
  assert.equal(listed.body.projects.length, 1);
});

test("contact submission works", async () => {
  const app = createApp(createServices());

  const response = await request(app).post("/api/contact").send({
    firstName: "Ada",
    email: "ada@example.com",
    message: "Hello",
  });
  assert.equal(response.status, 201);
  assert.equal(response.body.message.firstName, "Ada");
});

test("avatar and cv uploads return urls", async () => {
  const app = createApp(createServices());
  const cookie = await loginAndGetCookie(app);

  const avatar = await request(app)
    .post("/api/uploads/avatar")
    .set("Cookie", cookie)
    .attach("file", Buffer.from("avatar"), "avatar.png");
  assert.equal(avatar.status, 201);
  assert.match(avatar.body.url, /portfolio\/avatars/);

  const cv = await request(app)
    .post("/api/uploads/cv")
    .set("Cookie", cookie)
    .attach("file", Buffer.from("resume"), "resume.pdf");
  assert.equal(cv.status, 201);
  assert.match(cv.body.url, /portfolio\/cvs/);
});
