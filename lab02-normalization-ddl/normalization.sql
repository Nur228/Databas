DROP SCHEMA IF EXISTS receipt CASCADE;
CREATE SCHEMA receipt;
SET search_path TO receipt;

CREATE TABLE booking_receipt (
    booking_id                INT,
    passenger_full_name       VARCHAR(100),
    passenger_passport_number VARCHAR(20),
    flight_number             VARCHAR(10),
    departure_airport_name    VARCHAR(50),
    departure_city            VARCHAR(50),
    arrival_airport_name      VARCHAR(50),
    arrival_city              VARCHAR(50),
    airline_name              VARCHAR(50),
    seat_numbers              VARCHAR(100),
    ticket_price              DECIMAL(9,2)
);

INSERT INTO booking_receipt VALUES
 (1, 'Aidar Seitov',    'N1234567', 'KC921', 'Almaty International', 'Almaty', 'Astana International', 'Astana',   'Air Astana',      '12A, 12B',      60000),
 (2, 'Dana Omarova',    'N7654321', 'KC921', 'Almaty International', 'Almaty', 'Astana International', 'Astana',   'Air Astana',      '14C',           30000),
 (3, 'John Smith',      'P9988776', 'TK351', 'Astana International', 'Astana', 'Istanbul Airport',     'Istanbul', 'Turkish Airlines','3A',            120000),
 (4, 'Aidar Seitov',    'N1234567', 'DV707', 'Almaty International', 'Almaty', 'Shymkent International','Shymkent','SCAT Airlines',   '7D, 7E, 7F',    45000),
 (5, 'Maria Garcia',    'E5544332', 'TK351', 'Astana International', 'Astana', 'Istanbul Airport',     'Istanbul', 'Turkish Airlines','21B',           115000),
 (6, 'Dana Omarova',    'N7654321', 'DV707', 'Almaty International', 'Almaty', 'Shymkent International','Shymkent','SCAT Airlines',   '9A',            15000);

CREATE TABLE passenger (
    passport_number VARCHAR(20) PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL
);

CREATE TABLE airline (
    airline_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airline_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE airport (
    airport_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_name VARCHAR(50) NOT NULL UNIQUE,
    city         VARCHAR(50) NOT NULL
);

CREATE TABLE flight (
    flight_number        VARCHAR(10) PRIMARY KEY,
    airline_id           INT NOT NULL REFERENCES airline (airline_id),
    departure_airport_id INT NOT NULL REFERENCES airport (airport_id),
    arrival_airport_id   INT NOT NULL REFERENCES airport (airport_id)
);

CREATE TABLE booking (
    booking_id      INT PRIMARY KEY,
    passport_number VARCHAR(20) NOT NULL REFERENCES passenger (passport_number),
    flight_number   VARCHAR(10) NOT NULL REFERENCES flight (flight_number),
    ticket_price    DECIMAL(9,2) NOT NULL
);

CREATE TABLE booking_seat (
    booking_id  INT NOT NULL REFERENCES booking (booking_id),
    seat_number VARCHAR(5) NOT NULL,
    PRIMARY KEY (booking_id, seat_number)
);

INSERT INTO passenger (passport_number, first_name, last_name)
SELECT DISTINCT passenger_passport_number,
       split_part(passenger_full_name, ' ', 1),
       split_part(passenger_full_name, ' ', 2)
FROM booking_receipt;

INSERT INTO airline (airline_name)
SELECT DISTINCT airline_name FROM booking_receipt;

INSERT INTO airport (airport_name, city)
SELECT departure_airport_name, departure_city FROM booking_receipt
UNION
SELECT arrival_airport_name, arrival_city FROM booking_receipt;

INSERT INTO flight (flight_number, airline_id, departure_airport_id, arrival_airport_id)
SELECT DISTINCT r.flight_number, al.airline_id, dep.airport_id, arr.airport_id
FROM booking_receipt r
JOIN airline al  ON al.airline_name  = r.airline_name
JOIN airport dep ON dep.airport_name = r.departure_airport_name
JOIN airport arr ON arr.airport_name = r.arrival_airport_name;

INSERT INTO booking (booking_id, passport_number, flight_number, ticket_price)
SELECT booking_id, passenger_passport_number, flight_number, ticket_price
FROM booking_receipt;

INSERT INTO booking_seat (booking_id, seat_number)
SELECT booking_id, trim(unnest(string_to_array(seat_numbers, ',')))
FROM booking_receipt;

SELECT * FROM passenger;
SELECT * FROM airline;
SELECT * FROM airport;
SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_seat ORDER BY booking_id, seat_number;

SELECT b.booking_id,
       p.first_name || ' ' || p.last_name           AS passenger_full_name,
       b.flight_number, dep.city AS departure_city, arr.city AS arrival_city,
       al.airline_name,
       string_agg(s.seat_number, ', ' ORDER BY s.seat_number) AS seat_numbers,
       b.ticket_price
FROM booking b
JOIN passenger p    ON p.passport_number = b.passport_number
JOIN flight f       ON f.flight_number   = b.flight_number
JOIN airline al     ON al.airline_id     = f.airline_id
JOIN airport dep    ON dep.airport_id    = f.departure_airport_id
JOIN airport arr    ON arr.airport_id    = f.arrival_airport_id
JOIN booking_seat s ON s.booking_id      = b.booking_id
GROUP BY b.booking_id, p.first_name, p.last_name, b.flight_number,
         dep.city, arr.city, al.airline_name, b.ticket_price
ORDER BY b.booking_id;

RESET search_path;
