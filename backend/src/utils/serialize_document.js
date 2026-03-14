function serializeDocument(document) {
  if (!document) {
    return null;
  }

  const plain = typeof document.toObject === "function" ? document.toObject() : document;
  const { _id, __v, passwordHash, ...rest } = plain;

  return {
    id: _id ? _id.toString() : rest.id,
    ...rest,
  };
}

module.exports = {
  serializeDocument,
};
