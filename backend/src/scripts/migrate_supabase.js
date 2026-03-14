const path = require("path");
const { createClient } = require("@supabase/supabase-js");
const { connectToDatabase, disconnectFromDatabase } = require("../config/database");
const { env, requireEnv } = require("../config/env");
const { uploadBuffer } = require("../config/cloudinary");
const ContactMessage = require("../models/contact_message");
const Profile = require("../models/profile");
const Project = require("../models/project");
const { ensureAdmin } = require("../services/auth_service");
const { normalizeProfilePayload } = require("../utils/normalize_profile_payload");

function createSupabaseClient() {
  return createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

async function fetchTable(supabase, table) {
  const { data, error } = await supabase.from(table).select("*");
  if (error) {
    throw error;
  }
  return data || [];
}

function basenameWithoutExtension(url) {
  try {
    const parsed = new URL(url);
    return path.basename(parsed.pathname, path.extname(parsed.pathname));
  } catch (_) {
    return `asset-${Date.now()}`;
  }
}

async function uploadAssetFromUrl({ url, folder, resourceType, dryRun }) {
  if (!url) {
    return null;
  }

  if (dryRun) {
    return url;
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download asset from ${url}`);
  }

  const arrayBuffer = await response.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const uploaded = await uploadBuffer({
    buffer,
    folder,
    publicId: `${basenameWithoutExtension(url)}-${Date.now()}`,
    resourceType,
  });

  return uploaded.secure_url;
}

async function migrateProfile(supabase, { dryRun }) {
  const profiles = await fetchTable(supabase, "site_profile");
  const source = profiles[0] || null;

  if (!source) {
    return { migrated: false, sourceCount: 0 };
  }

  const avatarUrl = await uploadAssetFromUrl({
    url: source.avatar_url || null,
    folder: "portfolio/avatars",
    resourceType: "image",
    dryRun,
  });
  const cvUrl = await uploadAssetFromUrl({
    url: source.cv_url || null,
    folder: "portfolio/cvs",
    resourceType: "raw",
    dryRun,
  });

  const profilePayload = {
    ...normalizeProfilePayload(source),
    avatarUrl: avatarUrl || source.avatar_url || null,
    cvUrl: cvUrl || source.cv_url || null,
  };

  if (!dryRun) {
    await Profile.findOneAndUpdate(
      { singletonKey: "public" },
      {
        $set: {
          ...profilePayload,
          singletonKey: "public",
          legacySupabaseId: source.id || null,
          legacyCreatedAt: source.created_at ? new Date(source.created_at) : null,
          legacyUpdatedAt: source.updated_at ? new Date(source.updated_at) : null,
        },
      },
      {
        upsert: true,
        new: true,
        runValidators: true,
      },
    );
  }

  return { migrated: true, sourceCount: profiles.length };
}

async function migrateProjects(supabase, { dryRun }) {
  const projects = await fetchTable(supabase, "projects");

  if (!dryRun) {
    for (const project of projects) {
      await Project.findOneAndUpdate(
        { legacySupabaseId: project.id || `${project.title}-${project.url || ""}` },
        {
          $set: {
            legacySupabaseId: project.id || null,
            title: String(project.title || "").trim(),
            subtitle: String(project.subtitle || "").trim() || null,
            description: String(project.description || "").trim() || null,
            url: String(project.url || "").trim() || null,
            tags: Array.isArray(project.tags)
              ? project.tags.map((tag) => String(tag).trim()).filter(Boolean)
              : [],
            isActive:
              project.is_active === undefined ? true : Boolean(project.is_active),
            sortOrder: Number.isFinite(Number(project.sort_order))
              ? Number(project.sort_order)
              : 0,
            legacyCreatedAt: project.created_at
              ? new Date(project.created_at)
              : null,
            legacyUpdatedAt: project.updated_at
              ? new Date(project.updated_at)
              : null,
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
  }

  return { migrated: !dryRun || projects.length > 0, sourceCount: projects.length };
}

async function migrateContacts(supabase, { dryRun }) {
  const contacts = await fetchTable(supabase, "contact_messages");

  if (!dryRun) {
    for (const contact of contacts) {
      await ContactMessage.findOneAndUpdate(
        {
          legacySupabaseId:
            contact.id ||
            `${contact.email || ""}-${contact.created_at || ""}-${contact.message || ""}`,
        },
        {
          $set: {
            legacySupabaseId: contact.id || null,
            firstName: String(contact.first_name || "").trim() || "Visitor",
            lastName: String(contact.last_name || "").trim() || null,
            email: String(contact.email || "").trim().toLowerCase(),
            message: String(contact.message || "").trim(),
            legacyCreatedAt: contact.created_at ? new Date(contact.created_at) : null,
            legacyUpdatedAt: contact.updated_at ? new Date(contact.updated_at) : null,
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
  }

  return { migrated: !dryRun || contacts.length > 0, sourceCount: contacts.length };
}

async function run() {
  const dryRun = process.argv.includes("--dry-run");
  requireEnv("MONGODB_URI");
  requireEnv("SUPABASE_URL");
  requireEnv("SUPABASE_SERVICE_ROLE_KEY");

  await connectToDatabase();
  await ensureAdmin({
    email: env.adminEmail,
    password: env.adminPassword,
  });

  const supabase = createSupabaseClient();
  const profileSummary = await migrateProfile(supabase, { dryRun });
  const projectSummary = await migrateProjects(supabase, { dryRun });
  const contactSummary = await migrateContacts(supabase, { dryRun });

  console.log(
    JSON.stringify(
      {
        dryRun,
        profileSummary,
        projectSummary,
        contactSummary,
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
