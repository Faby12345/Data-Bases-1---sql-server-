
IF DB_ID('AirportDB') IS NOT NULL
BEGIN
    ALTER DATABASE AirportDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AirportDB;
END;
GO

CREATE DATABASE AirportDB;
GO

USE AirportDB;
GO

/* ===== 1) Tables =====
   Airports (1) ──< Flights (N)
   Flights  (1) ──< Bookings (N)
   Passengers (1) ──< Bookings (N)

   So:
   - An airport can have many flights
   - A flight can have many passengers
   - A passenger can be on many flights (through Bookings)
*/

-- We'll DROP the tables first in case you re-run this script.
IF OBJECT_ID('dbo.Bookings')    IS NOT NULL DROP TABLE dbo.Bookings;
IF OBJECT_ID('dbo.Flights')     IS NOT NULL DROP TABLE dbo.Flights;
IF OBJECT_ID('dbo.Passengers')  IS NOT NULL DROP TABLE dbo.Passengers;
IF OBJECT_ID('dbo.Airports')    IS NOT NULL DROP TABLE dbo.Airports;
GO

-- Airports: basic info about each airport
CREATE TABLE dbo.Airports (
                              AirportId INT IDENTITY(1,1) PRIMARY KEY,
                              Code      CHAR(3)        NOT NULL UNIQUE,       -- e.g. OTP, LHR
                              Name      NVARCHAR(200)  NOT NULL,
                              City      NVARCHAR(100)  NOT NULL,
                              Country   NVARCHAR(100)  NOT NULL
);

-- Flights: each row is one scheduled flight
CREATE TABLE dbo.Flights (
                             FlightId    INT IDENTITY(1,1) PRIMARY KEY,
                             FlightNo    NVARCHAR(10) NOT NULL,              -- e.g. RO301, LH123
                             FromAirport INT NOT NULL
                                 CONSTRAINT FK_Flights_FromAirport
                                     REFERENCES dbo.Airports(AirportId),
                             ToAirport   INT NOT NULL
                                 CONSTRAINT FK_Flights_ToAirport
                                     REFERENCES dbo.Airports(AirportId),
                             DepartureTime DATETIME2 NOT NULL,
                             ArrivalTime   DATETIME2 NOT NULL
);

-- Passengers: people who can book seats on flights
CREATE TABLE dbo.Passengers (
                                PassengerId INT IDENTITY(1,1) PRIMARY KEY,
                                FullName    NVARCHAR(100) NOT NULL,
                                Email       NVARCHAR(200) UNIQUE
);

-- Bookings: which passenger is on which flight
CREATE TABLE dbo.Bookings (
                              BookingId    INT IDENTITY(1,1) PRIMARY KEY,
                              PassengerId  INT NOT NULL
                                  CONSTRAINT FK_Bookings_Passengers
                                      REFERENCES dbo.Passengers(PassengerId),
                              FlightId     INT NOT NULL
                                  CONSTRAINT FK_Bookings_Flights
                                      REFERENCES dbo.Flights(FlightId),
                              SeatNumber   NVARCHAR(5) NOT NULL,              -- e.g. 12A
                              BookingTime  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                              CONSTRAINT UQ_Passenger_Flight UNIQUE (PassengerId, FlightId) -- same passenger can't book same flight twice
);

-- Helpful indexes for lookups
CREATE INDEX IX_Flights_FromAirport ON dbo.Flights(FromAirport);
CREATE INDEX IX_Flights_ToAirport   ON dbo.Flights(ToAirport);
CREATE INDEX IX_Bookings_Passenger  ON dbo.Bookings(PassengerId);
CREATE INDEX IX_Bookings_Flight     ON dbo.Bookings(FlightId);
GO

/* ===== 2) Inser*
