# RaceDay API Endpoint Plan

This document lists every endpoint the RaceDay REST API will expose. It is the
specification for Part 2 — the implemented API must closely match this plan.

**Roles:** `None` = public, `Any` = any authenticated user, `Organiser` /
`Participant` = that role only.

---

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new account as either an Organiser or a Participant and hashes the password before storing it. | None | `{ firstName, lastName, email, password, phoneNumber, role }` | 201 Created – new user summary (no password) · 400 Bad Request – validation failed · 409 Conflict – email already registered |
| POST | /api/auth/login | Authenticates a user and starts a session storing the user's ID and role. | None | `{ email, password }` | 200 OK – user summary and role · 401 Unauthorized – invalid credentials |
| POST | /api/auth/logout | Ends the current session. | Any | None | 200 OK – logged out |

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the logged-in user's own profile. | Any | None | 200 OK – user profile · 401 Unauthorized |
| PUT | /api/users/me | Updates the logged-in user's own profile details. | Any | `{ firstName, lastName, phoneNumber }` | 200 OK – updated profile · 400 Bad Request · 401 Unauthorized |
| POST | /api/users/me/profile-picture | Uploads/replaces the logged-in user's profile picture. | Any | multipart file | 200 OK – profile picture URL · 400 Bad Request |

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all upcoming events, with optional filtering (type, location, date). | None | None | 200 OK – array of events |
| GET | /api/events/{id} | Returns full details for a single event, including its categories. | None | None | 200 OK – event details · 404 Not Found |
| POST | /api/events | Creates a new event owned by the logged-in Organiser. | Organiser | `{ name, description, eventDate, location, distanceKm, eventType }` | 201 Created – new event · 400 Bad Request · 401 Unauthorized · 403 Forbidden |
| PUT | /api/events/{id} | Updates an event owned by the logged-in Organiser. | Organiser | `{ name, description, eventDate, location, distanceKm, eventType }` | 200 OK – updated event · 403 Forbidden (not the owner) · 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event owned by the logged-in Organiser. | Organiser | None | 204 No Content · 403 Forbidden · 404 Not Found |
| POST | /api/events/{id}/banner | Uploads a banner image for the event to Azure Blob Storage. | Organiser | multipart file | 200 OK – banner URL · 403 Forbidden · 404 Not Found |

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories available for a specific event. | None | None | 200 OK – array of categories · 404 Not Found |
| POST | /api/events/{eventId}/categories | Adds a new age/distance category to an event owned by the Organiser. | Organiser | `{ name, minAge, maxAge, distanceKm }` | 201 Created – new category · 403 Forbidden · 404 Not Found |
| PUT | /api/categories/{id} | Updates an existing category. | Organiser | `{ name, minAge, maxAge, distanceKm }` | 200 OK – updated category · 403 Forbidden · 404 Not Found |
| DELETE | /api/categories/{id} | Removes a category from an event. | Organiser | None | 204 No Content · 403 Forbidden · 404 Not Found |

## 5. Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/events/{eventId}/enrolments | Enrols the logged-in Participant into the event under the chosen category. | Participant | `{ categoryId }` | 201 Created – enrolment record · 400 Bad Request · 401 Unauthorized · 404 Not Found · 409 Conflict (already enrolled) |
| GET | /api/users/me/enrolments | Lists all events the logged-in Participant has enrolled in. | Participant | None | 200 OK – array of enrolments |
| GET | /api/events/{eventId}/enrolments | Lists all Participants enrolled in an event owned by the Organiser. | Organiser | None | 200 OK – array of enrolments (with participant + category) · 403 Forbidden · 404 Not Found |
| DELETE | /api/enrolments/{id} | Cancels a Participant's own enrolment. | Participant | None | 204 No Content · 403 Forbidden · 404 Not Found |

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/results | Captures and publishes a finish time and position for an enrolled Participant. | Organiser | `{ finishTime, finishPosition, totalFinishers }` | 201 Created – result record · 400 Bad Request · 403 Forbidden · 404 Not Found |
| PUT | /api/results/{id} | Updates a previously captured result. | Organiser | `{ finishTime, finishPosition, totalFinishers }` | 200 OK – updated result · 403 Forbidden · 404 Not Found |
| GET | /api/users/me/results | Returns the logged-in Participant's personal race history across all completed events. | Participant | None | 200 OK – array of results with event name, date, category, finish time and position |
| GET | /api/events/{eventId}/results | Returns the full published results list for an event (for the Organiser view). | Organiser | None | 200 OK – array of results · 403 Forbidden · 404 Not Found |

---

*This plan covers Authentication, User Profile, Events, Categories, Event
Enrolments and Results as required, plus supporting endpoints (logout,
profile picture upload, banner upload, enrolment cancellation) identified as
necessary while planning. The Part 2 implementation must match this table;
any deviation will be explained in the Part 2 README.*
