const { connectToDatabase, disconnectFromDatabase } = require("../config/database");
const { requireEnv } = require("../config/env");
const Project = require("../models/project");

const manualProjects = [
  {
    title: "Gafars Technologies Portfolio",
    subtitle: "Flutter Web • MongoDB • Netlify",
    description:
      "Admin-managed portfolio platform with a Render-hosted MongoDB API, Cloudinary uploads, and a Netlify-hosted Flutter web frontend.",
    url: "https://gafarstechnologies.com",
    tags: ["flutter", "portfolio", "mongodb", "render", "netlify", "web"],
    isActive: true,
    sortOrder: 0,
  },
  {
    legacySupabaseId: "manual-focus-mission",
    title: "Focus Mission",
    subtitle: "Flutter Web • MongoDB • Learning Platform",
    description:
      "A role-based learning platform with student, teacher, and mentor workspaces, mission-driven progress flows, analytics, and a Render-hosted MongoDB backend.",
    url: "https://flexiblelearning.gafarstechnologies.com/",
    tags: ["flutter", "mongodb", "render", "education", "analytics"],
    isActive: true,
    sortOrder: 1,
  },
];

async function upsertProject(project) {
  const query = project.legacySupabaseId
    ? { legacySupabaseId: project.legacySupabaseId }
    : project.url
      ? { url: project.url }
      : { title: project.title };

  return Project.findOneAndUpdate(
    query,
    {
      $set: {
        ...(project.legacySupabaseId
            ? { legacySupabaseId: project.legacySupabaseId }
            : {}),
        title: project.title,
        subtitle: project.subtitle,
        description: project.description,
        url: project.url,
        tags: project.tags,
        isActive: project.isActive,
        sortOrder: project.sortOrder,
      },
    },
    {
      upsert: true,
      new: true,
      runValidators: true,
      setDefaultsOnInsert: true,
    },
  );
}

async function run() {
  requireEnv("MONGODB_URI");

  await connectToDatabase();
  await Project.deleteMany({
    $or: [
      { legacySupabaseId: "manual-flexible-learning" },
      {
        title: "Flexible Learning",
        url: "https://flexiblelearning.gafarstechnologies.com/",
      },
    ],
  });
  const seededProjects = [];

  for (const project of manualProjects) {
    const seeded = await upsertProject(project);
    seededProjects.push({
      id: seeded._id.toString(),
      title: seeded.title,
      url: seeded.url,
    });
  }

  console.log(
    JSON.stringify(
      {
        seededCount: seededProjects.length,
        projects: seededProjects,
      },
      null,
      2,
    ),
  );
}

run()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectFromDatabase();
  });
