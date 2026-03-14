# Repo Structure

- `gafars_portfolio/` contains the Flutter web frontend deployed to Netlify.
- `backend/` contains the Express API deployed to Render.

# Runtime Rules

- The Flutter app must never connect directly to MongoDB.
- All writes, admin auth, and uploads must go through the backend API.
- DiceBear avatar fallback is client-side and generated in `avatar_presets.dart`.
- Uploaded avatars and CVs are stored through Cloudinary-backed backend endpoints.

# Environment

- Frontend runtime config uses `API_BASE_URL`.
- Backend runtime config lives in `backend/.env` and should be based on `backend/.env.example`.
- Supabase credentials are only used by migration scripts and must not be used by the Flutter app.

# Migration

- Seed and migration commands live under `backend/src/scripts/`.
- `npm run seed:admin` ensures the configured admin exists.
- `npm run migrate:supabase -- --dry-run` validates source access before writing data.
- `npm run migrate:supabase` imports profile, projects, contacts, and referenced media assets into MongoDB/Cloudinary.

# Deployment Rule

- After any code change in `gafars_portfolio/` or `backend/`, do not stop at implementation only.
- Before finishing, always either ask whether to deploy now or provide the exact push and deploy commands.
- For frontend changes, provide `git push`, `cd gafars_portfolio && flutter build web --release`, and `cd gafars_portfolio && netlify deploy --dir=build/web --prod`.
- For backend changes, provide `git push` and the Render deploy step if needed.
- For changes affecting both frontend and backend, provide both command sets.
- Never imply a deploy happened unless it was actually run.
