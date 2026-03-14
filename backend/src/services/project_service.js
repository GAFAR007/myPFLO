const Project = require("../models/project");
const { serializeDocument } = require("../utils/serialize_document");

function normalizeTags(rawTags) {
  if (!Array.isArray(rawTags)) {
    return [];
  }

  return rawTags
    .map((tag) => String(tag).trim())
    .filter(Boolean);
}

async function listPublicProjects() {
  const projects = await Project.find({ isActive: true }).sort({
    sortOrder: 1,
    createdAt: -1,
  });
  return projects.map(serializeDocument);
}

async function createProject(payload) {
  const title = String(payload.title || "").trim();
  if (!title) {
    const error = new Error("Project title is required.");
    error.statusCode = 400;
    throw error;
  }

  const project = await Project.create({
    title,
    subtitle: String(payload.subtitle || "").trim() || null,
    description: String(payload.description || "").trim() || null,
    url: String(payload.url || "").trim() || null,
    tags: normalizeTags(payload.tags),
    isActive: payload.isActive !== undefined ? Boolean(payload.isActive) : true,
    sortOrder: Number.isFinite(Number(payload.sortOrder))
      ? Number(payload.sortOrder)
      : 0,
  });

  return serializeDocument(project);
}

module.exports = {
  createProject,
  listPublicProjects,
};
