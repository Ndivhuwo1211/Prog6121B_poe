# RaceDay

RaceDay is a full-stack web-based event management system built for the
South African road running, walking, and cycling community. It replaces the
paper-based registration, spreadsheets, and disconnected communication that
many local road events still rely on.

The platform lets **Event Organisers** create and manage events, define
categories, and capture participant results, while **Participants** can
browse upcoming events, enter events, track their personal performance
history, and prepare for race day.

This repository is submitted progressively as a three-part Portfolio of
Evidence (POE) for PROG6212/w — Programming 2B. This README covers **Part 1:
System Planning and Database**.

---

## Roles

| Role | What they can do |
|---|---|
| **Organiser** | Create, edit, and delete events; manage event categories; capture participant results; view all enrolments for their events. |
| **Participant** | Register an account; browse events; enter an event by selecting a category; view their own enrolments; track their personal results. |

---

## Part 1 — Planning Documents

All planning documents for this part are committed inside the `/docs` folder:

| File | Description |
|---|---|
| `docs/RaceDay_ERD.png` (or `.pdf`) | Entity Relationship Diagram — 6 entities (Roles, Users, Events, Categories, Enrolments, Results) with primary keys, foreign keys, and cardinality. |
| `docs/API_Endpoint_Plan.md` (or `.pdf`) | Full endpoint plan covering Authentication, User Profile, Events, Categories, Event Enrolments, and Results — HTTP method, route, description, role required, request body, and expected response for every endpoint. |
| `docs/RaceDay_Database.sql` | SQL Server script that creates the full schema (with primary keys, foreign keys, and constraints) and seeds it with sample data: 2 Organisers, 2 Participants, 3 Events, categories per event, and sample enrolments. |

No application code is written in Part 1 — this part is planning only.

---

## Running the SQL Script

1. Open **SQL Server Management Studio (SSMS)** and connect to a local or
   clean SQL Server instance.
2. Open `docs/RaceDay_Database.sql`.
3. Execute the script (F5). It will:
   - Drop and recreate the `RaceDayDB` database
   - Create all six tables with their constraints
   - Seed the database with sample Organisers, Participants, Events,
     Categories, Enrolments, and a sample Result
4. Verify the tables and seed data under **Databases > RaceDayDB > Tables**.

---

## CI/CD

A GitHub Actions workflow at `.github/workflows/part1-validate-docs.yml` runs
on every push and validates that:
- the `/docs` folder exists,
- it contains the ERD and API endpoint plan (PDF/PNG/JPG),
- it contains the `.sql` database script, and
- `README.md` exists at the repository root.

**Green build screenshot:**
<img width="1335" height="641" alt="image" src="https://github.com/user-attachments/assets/f518d744-5962-4918-9468-c61680ab9bf1" />

`
---

## Video Presentation

An unlisted YouTube video walking through the ERD decisions, the endpoint
plan choices, and a live run of the SQL script in SSMS:

`[Insert your unlisted YouTube link here]`

---

