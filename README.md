# myPFLO

Personal portfolio platform with:

- Flutter web frontend in `gafars_portfolio/`
- Express + MongoDB backend in `backend/`
- Cloudinary-backed uploads for profile media
- DiceBear `adventurer` avatar fallback when no profile image exists

## Local setup

1. Copy `backend/.env.example` to `backend/.env` and fill in MongoDB, Cloudinary, Supabase migration, and admin values.
2. Install backend dependencies with `cd backend && npm install`.
3. Install Flutter dependencies with `cd gafars_portfolio && flutter pub get`.
4. Run the backend with `npm start` inside `backend/`.
5. Run the frontend with:

```bash
cd gafars_portfolio
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

## Migration

- Dry run: `cd backend && npm run migrate:supabase -- --dry-run`
- Import data: `cd backend && npm run migrate:supabase`
- Seed/update the admin account: `cd backend && npm run seed:admin`
- Seed manual portfolio projects: `cd backend && npm run seed:projects`
