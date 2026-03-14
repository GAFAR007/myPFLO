function toNullableString(value) {
  if (value === undefined) {
    return undefined;
  }

  if (value === null) {
    return null;
  }

  const stringValue = String(value).trim();
  return stringValue.length === 0 ? null : stringValue;
}

function read(payload, ...keys) {
  for (const key of keys) {
    if (Object.prototype.hasOwnProperty.call(payload, key)) {
      return payload[key];
    }
  }
  return undefined;
}

function normalizeDate(value) {
  if (value === undefined) {
    return undefined;
  }

  if (value === null || value === "") {
    return null;
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error("Invalid dateOfBirth/date_of_birth value.");
  }
  return parsed;
}

function normalizeProfilePayload(payload = {}) {
  const normalized = {
    fullName: toNullableString(read(payload, "fullName", "full_name")),
    title: toNullableString(read(payload, "title")),
    email: toNullableString(read(payload, "email")),
    tagline: toNullableString(read(payload, "tagline")),
    aboutMd: toNullableString(read(payload, "aboutMd", "about_md")),
    phoneE164: toNullableString(read(payload, "phoneE164", "phone_e164")),
    phone: toNullableString(read(payload, "phone")),
    linkedin: toNullableString(read(payload, "linkedin")),
    cvUrl: toNullableString(read(payload, "cvUrl", "cv_url")),
    github: toNullableString(read(payload, "github")),
    twitter: toNullableString(read(payload, "twitter")),
    website: toNullableString(read(payload, "website")),
    location: toNullableString(read(payload, "location")),
    avatarUrl: toNullableString(read(payload, "avatarUrl", "avatar_url")),
    firstName: toNullableString(read(payload, "firstName", "first_name")),
    middleName: toNullableString(read(payload, "middleName", "middle_name")),
    lastName: toNullableString(read(payload, "lastName", "last_name")),
    dateOfBirth: normalizeDate(read(payload, "dateOfBirth", "date_of_birth")),
  };

  Object.keys(normalized).forEach((key) => {
    if (normalized[key] === undefined) {
      delete normalized[key];
    }
  });

  if (!("fullName" in normalized)) {
    const nameParts = [
      normalized.firstName,
      normalized.middleName,
      normalized.lastName,
    ].filter(Boolean);
    if (nameParts.length > 0) {
      normalized.fullName = nameParts.join(" ");
    }
  }

  return normalized;
}

module.exports = {
  normalizeProfilePayload,
};
