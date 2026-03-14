const { connectToDatabase, disconnectFromDatabase } = require("../config/database");
const { requireEnv } = require("../config/env");
const Project = require("../models/project");

const manualProjects = [
  {
    title: "Flexible Learning",
    subtitle: "Flutter Web • E-Learning",
    description:
      "A web-based learning platform built to support flexible digital education experiences.",
    url: "https://flexiblelearning.gafarstechnologies.com/",
    tags: ["flutter", "education", "web"],
    isActive: true,
    sortOrder: 1,
  },
];

async function upsertProject(project) {
  if (!project.url) {
    throw new Error(`Project "${project.title}" is missing a URL.`);
  }

  return Project.findOneAndUpdate(
    { url: project.url },
    {
      $set: {
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
