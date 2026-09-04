/* ============================================================
   RaceDay Database Script
   Module: PROG6212/w - Programming 2B - POE Part 1
   .

   
   ============================================================ */

USE master;
GO

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

/* ------------------------------------------------------------
   1. Roles
   ------------------------------------------------------------ */
CREATE TABLE Roles (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(20) NOT NULL UNIQUE
);
GO

/* ------------------------------------------------------------
   2. Users
   ------------------------------------------------------------ */
CREATE TABLE Users (
    UserId              INT IDENTITY(1,1) PRIMARY KEY,
    RoleId              INT NOT NULL,
    FirstName           NVARCHAR(50)  NOT NULL,
    LastName            NVARCHAR(50)  NOT NULL,
    Email               NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(255) NOT NULL,
    PhoneNumber         NVARCHAR(20)  NULL,
    ProfilePictureUrl   NVARCHAR(255) NULL,
    CreatedAt           DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);
GO

/* ------------------------------------------------------------
   3. Events
   ------------------------------------------------------------ */
CREATE TABLE Events (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT NOT NULL,
    Name            NVARCHAR(150) NOT NULL,
    Description     NVARCHAR(MAX) NOT NULL,
    EventDate       DATETIME NOT NULL,
    Location        NVARCHAR(150) NOT NULL,
    DistanceKm      DECIMAL(6,2) NOT NULL,
    EventType       NVARCHAR(10) NOT NULL,
    BannerImageUrl  NVARCHAR(255) NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Events_EventType CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);
GO

/* ------------------------------------------------------------
   4. Categories
   ------------------------------------------------------------ */
CREATE TABLE Categories (
    CategoryId  INT IDENTITY(1,1) PRIMARY KEY,
    EventId     INT NOT NULL,
    Name        NVARCHAR(50) NOT NULL,
    MinAge      INT NULL,
    MaxAge      INT NULL,
    DistanceKm  DECIMAL(6,2) NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE
);
GO

/* ------------------------------------------------------------
   5. Enrolments
   ------------------------------------------------------------ */
CREATE TABLE Enrolments (
    EnrolmentId     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId   INT NOT NULL,
    EventId         INT NOT NULL,
    CategoryId      INT NOT NULL,
    EnrolmentDate   DATETIME NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventId) REFERENCES Events(EventId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantId, EventId)
);
GO

/* ------------------------------------------------------------
   6. Results
   ------------------------------------------------------------ */
CREATE TABLE Results (
    ResultId        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT NOT NULL UNIQUE,
    FinishTime      TIME NULL,
    FinishPosition  INT NULL,
    TotalFinishers  INT NULL,
    PublishedAt     DATETIME NULL,
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

/* ============================================================
   SEED DATA
   ============================================================ */

INSERT INTO Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

-- 2 Organisers, 2 Participants
INSERT INTO Users (RoleId, FirstName, LastName, Email, PasswordHash, PhoneNumber)
VALUES
(1, 'Naledi', 'Khumalo',  'naledi.khumalo@raceday.co.za',  'HASHED_PASSWORD_1', '0821234567'),
(1, 'Pieter', 'van Wyk',  'pieter.vanwyk@raceday.co.za',   'HASHED_PASSWORD_2', '0827654321'),
(2, 'Thando', 'Mokoena',  'thando.mokoena@example.com',    'HASHED_PASSWORD_3', '0731112222'),
(2, 'Sarah',  'Botha',    'sarah.botha@example.com',       'HASHED_PASSWORD_4', '0739998888');
GO

-- 3 Events (owned by the two Organisers)
INSERT INTO Events (OrganiserId, Name, Description, EventDate, Location, DistanceKm, EventType)
VALUES
(1, 'Johannesburg City Half Marathon', 'A scenic half marathon through the streets of Johannesburg.', '2026-11-15 06:00:00', 'Johannesburg, Gauteng', 21.10, 'Run'),
(2, 'Cape Winelands Cycle Challenge', 'A cycling event through the Cape Winelands region.', '2026-10-04 07:00:00', 'Stellenbosch, Western Cape', 94.70, 'Cycle'),
(1, 'Soweto Community Fun Walk', 'A family-friendly fun walk supporting local charities.', '2026-09-27 08:00:00', 'Soweto, Gauteng', 5.00, 'Walk');
GO

-- Categories for each event
INSERT INTO Categories (EventId, Name, MinAge, MaxAge, DistanceKm)
VALUES
(1, '21km Senior',   20, 39, 21.10),
(1, '21km Veteran',  40, 99, 21.10),
(2, '94km Open',     18, 99, 94.70),
(2, '47km Half',     18, 99, 47.00),
(3, '5km Family',    NULL, NULL, 5.00);
GO

-- Sample enrolments
INSERT INTO Enrolments (ParticipantId, EventId, CategoryId, Status)
VALUES
(3, 1, 1, 'Confirmed'),
(4, 2, 3, 'Confirmed'),
(3, 3, 5, 'Pending');
GO

-- Sample result for a completed enrolment
INSERT INTO Results (EnrolmentId, FinishTime, FinishPosition, TotalFinishers, PublishedAt)
VALUES
(1, '01:45:32', 47, 312, GETDATE());
GO
