# RaceDay

RaceDay is a full-stack web-based event management system built for the
South African road running, walking, and cycling community. It replaces the
paper-based registration, spreadsheets, and disconnected communication that
many local road events still rely on.

**Event Organisers** create and manage events, categories, and participant
results. **Participants** browse upcoming events, enter events, track their
personal performance history, and prepare for race day.

This repository is the Portfolio of Evidence (POE) for PROG6212/w —
Programming 2B, built progressively across three parts.

| Part | Folder | Status |
|---|---|---|
| Part 1 — Planning and Database | `/docs` | Complete |
| Part 2 — RESTful API | `/Part2-API` | Complete |
| Part 3 — MVC web app, Azure Blob Storage, Docker | `/Part3-MVC` (to come) | Not started |

---

## Roles

| Role | What they can do |
|---|---|
| **Organiser** | Create, edit, and delete their own events; manage event categories; confirm enrolments; capture participant results; view all enrolments and results for their events. |
| **Participant** | Register an account; browse events; enter an event by selecting a category; view and cancel their own enrolments; view their own results; manage their profile. |

Both roles can view and update their own profile and browse events and categories.

---

# Part 2 — RESTful API

An ASP.NET Core 8 Web API using Entity Framework Core (Code-First) with SQL
Server, server-side session authentication, role-based access control,
Swagger, and an xUnit test suite run by GitHub Actions.

## Project structure

```
Part2-API/
├── RaceDay.sln
├── src/RaceDay.Api/
│   ├── Controllers/    Auth, Users, Events, Categories, Enrolments, Results
│   ├── Models/         Entities matching the Part 1 ERD
│   ├── Data/           RaceDayDbContext (EF Core) and DbSeeder
│   ├── Dtos/           Request/response models + mappings
│   ├── Security/       Session keys, [SessionAuthorize] attribute, base controller
│   ├── Services/       Password hashing, file storage
│   └── Program.cs      Startup, session, Swagger
└── tests/RaceDay.Api.Tests/   xUnit tests (in-memory API + database)
```

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- SQL Server or SQL Server Express (the same instance used in SSMS for Part 1)
- EF Core CLI tool: `dotnet tool install --global dotnet-ef`

## Setup and run

1. **Check the connection string** in `Part2-API/src/RaceDay.Api/appsettings.json`.
   The default is `Server=localhost\SQLEXPRESS;Database=RaceDayApiDB;...`.
   Change the server name if yours differs (e.g. `YOUR-PC-NAME\SQLEXPRESS`).
   The API uses its own database (`RaceDayApiDB`) so it does not clash with
   the `RaceDayDB` created by the Part 1 SQL script.
2. **Create the initial migration** (once, *before the first run*):
   ```bash
   cd Part2-API
   dotnet ef migrations add InitialCreate --project src/RaceDay.Api
   ```
3. **Run the API.** The database is created/migrated automatically on startup
   and seeded with demo data in Development:
   ```bash
   dotnet run --project src/RaceDay.Api
   ```
4. Open **http://localhost:5080/swagger** (the root URL redirects there).

### Demo logins (Development only)

| Role | Email | Password |
|---|---|---|
| Organiser | `naledi.khumalo@raceday.co.za` | `Organiser@123` |
| Participant | `thando.mokoena@example.com` | `Participant@123` |

To try the API: expand `POST /api/auth/login`, click **Try it out**, log in,
then call any other endpoint. The session cookie is sent automatically.

## Authentication and role-based access

- **Registration** (`POST /api/auth/register`): the user supplies their details
  and chooses a role. Participants can self-register. Because letting anyone
  pick "Organiser" would defeat role-based security, registering as an
  Organiser also requires a secret `organiserCode` (configured in
  `appsettings.json` → `Registration:OrganiserCode`).
- **Passwords** are hashed with salted PBKDF2 (HMAC-SHA256, 100,000
  iterations) and are never stored or returned in plain text.
- **Login** (`POST /api/auth/login`) creates a **server-side session** that
  stores the user's ID and role; the browser only holds a session-ID cookie.
  Logging out clears the session.
- **Enforcement**: every protected endpoint uses `[SessionAuthorize]`.
  No session → **401 Unauthorized**. Wrong role → **403 Forbidden**.
  Organisers can only modify events (and their categories, enrolments and
  results) that they created; Participants can only see and cancel their own
  enrolments and see their own results.

## Endpoints

| Area | Endpoint | Role |
|---|---|---|
| Auth | `POST /api/auth/register`, `POST /api/auth/login` | Public |
| Auth | `POST /api/auth/logout` | Any |
| Profile | `GET/PUT /api/users/me`, `POST /api/users/me/profile-picture` | Any |
| Events | `GET /api/events`, `GET /api/events/{id}` | Public |
| Events | `POST /api/events`, `PUT/DELETE /api/events/{id}`, `POST /api/events/{id}/banner`, `GET /api/events/mine` | Organiser |
| Categories | `GET /api/events/{eventId}/categories` | Public |
| Categories | `POST /api/events/{eventId}/categories`, `PUT/DELETE /api/categories/{id}` | Organiser |
| Enrolments | `POST /api/events/{eventId}/enrolments`, `GET /api/users/me/enrolments`, `DELETE /api/enrolments/{id}` | Participant |
| Enrolments | `GET /api/events/{eventId}/enrolments`, `PUT /api/enrolments/{id}/status` | Organiser |
| Results | `GET /api/users/me/results` | Participant |
| Results | `POST /api/enrolments/{enrolmentId}/results`, `PUT /api/results/{id}`, `GET /api/events/{eventId}/results` | Organiser |

Full request/response detail for each endpoint is visible in Swagger UI.

## Deviations from the Part 1 plan

The implementation follows `docs/` closely. These are the intentional changes:

| Change | Reason |
|---|---|
| `POST /api/auth/register` also accepts `organiserCode` (required only for Organisers). | Stops users granting themselves Organiser rights. |
| **Added** `GET /api/events/mine` (Organiser). | Needed for the Part 3 Organiser dashboard (own events + enrolment totals). |
| **Added** `PUT /api/enrolments/{id}/status` (Organiser). | Lets Organisers move an enrolment from Pending to Confirmed (Part 3 colour-coded statuses). |
| `DELETE /api/events/{id}` and `DELETE /api/categories/{id}` return **409 Conflict** when enrolments exist. | The ERD uses `NO ACTION` on Enrolments' foreign keys, so deleting would violate referential integrity. |
| Image upload endpoints (`/banner`, `/profile-picture`) currently store files on local disk (`wwwroot/uploads`) behind an `IFileStorageService`. | Azure Blob Storage is Part 3; the interface lets it be swapped in without changing controllers. |
| New enrolments start as `Pending`. | Matches the `Status` column default in the SQL script. |

The database schema generated by EF Core matches the Part 1 ERD and SQL script
(same tables, columns, keys, unique constraints, check constraints and delete
behaviour).

## Unit tests

The `RaceDay.Api.Tests` project boots the real API in memory
(`WebApplicationFactory`) with the EF Core in-memory provider, so tests need no
SQL Server. They cover registration, login/logout and sessions, password
hashing, event management, categories, enrolments, results, and — through
parameterised tests — role enforcement (401/403) on **every** protected
endpoint.

```bash
cd Part2-API
dotnet test
```

## CI/CD

`.github/workflows/part2-build-test.yml` restores, builds, and runs all unit
tests on every push. `.github/workflows/part1-validate-docs.yml` validates the
repository structure (`/docs` contents and this README).

**Green build screenshot:**

`[Insert successful green build screenshot here]`

## Video presentation

Unlisted YouTube walkthrough of the running API, code structure, endpoints,
authentication, Swagger and the unit tests:

`[Insert unlisted YouTube link here — Part 2]`

---

# Part 1 — Planning and Database

All planning documents are in the `/docs` folder:

| File | Description |
|---|---|
| ERD (PNG/PDF) | 6 entities (Roles, Users, Events, Categories, Enrolments, Results) with PKs, FKs and cardinality. |
| API Endpoint Plan (PDF/MD) | Every endpoint with method, route, description, role, request body and responses. |
| `RaceDay_Database.sql` | SQL Server script: schema, constraints and seed data. |

**Running the SQL script:** open it in SSMS, connect to your instance, and
execute. It switches to `master`, drops and recreates `RaceDayDB`, creates the
six tables, and seeds 2 Organisers, 2 Participants, 3 Events, categories,
enrolments and a sample result.

**Video (Part 1):** `[Insert unlisted YouTube link here — Part 1]`

---

## AI Usage Disclosure

`[Briefly disclose here how AI tools were used in planning, proofreading, or
coding, as required by the assignment instructions. Explain which parts you
reviewed, modified and understand.]`
