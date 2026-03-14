const ContactMessage = require("../models/contact_message");
const { serializeDocument } = require("../utils/serialize_document");

async function createContactMessage(payload) {
  const firstName = String(payload.firstName || "").trim();
  const email = String(payload.email || "").trim().toLowerCase();
  const message = String(payload.message || "").trim();

  if (!firstName || !email || !message) {
    const error = new Error("firstName, email, and message are required.");
    error.statusCode = 400;
    throw error;
  }

  const contactMessage = await ContactMessage.create({
    firstName,
    lastName: String(payload.lastName || "").trim() || null,
    email,
    subject: String(payload.subject || "").trim() || null,
    message,
  });

  return serializeDocument(contactMessage);
}

module.exports = {
  createContactMessage,
};
