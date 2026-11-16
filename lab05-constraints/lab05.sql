-- Task 1

SELECT passenger_id, first_name, date_of_birth, AGE(date_of_birth) AS age
FROM passengers
WHERE date_of_birth > CURRENT_DATE - INTERVAL '10 years';

ALTER TABLE passengers
    ADD CONSTRAINT chk_passenger_min_age
    CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '10 years') NOT VALID;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Test', 'Child', CURRENT_DATE - INTERVAL '5 years', 'Male', 'Kazakhstan',
        'Kazakhstan', 'TEST0001', now(), now());

-- Task 2

SELECT booking_id, ticket_price FROM booking WHERE ticket_price NOT BETWEEN 0 AND 50000;

UPDATE booking SET ticket_price = 50000 WHERE ticket_price > 50000
RETURNING booking_id, ticket_price;

ALTER TABLE booking
    ADD CONSTRAINT chk_booking_price
    CHECK (ticket_price BETWEEN 0 AND 50000);

UPDATE booking SET ticket_price = 70000 WHERE booking_id = (SELECT MIN(booking_id) FROM booking);

-- Task 3

SELECT baggage_id, weight_in_kg FROM baggage WHERE weight_in_kg NOT BETWEEN 1 AND 23;

ALTER TABLE baggage
    ADD CONSTRAINT chk_baggage_weight
    CHECK (weight_in_kg BETWEEN 1 AND 23) NOT VALID;

INSERT INTO baggage (weight_in_kg, created_at, updated_at, booking_id)
VALUES (30, now(), now(), (SELECT MIN(booking_id) FROM booking));

-- Task 4

SELECT airport_id, airport_name, LENGTH(airport_name) FROM airport WHERE LENGTH(airport_name) < 10;

UPDATE airport SET airport_name = airport_name || ' Airport', updated_at = now()
WHERE LENGTH(airport_name) < 10
RETURNING airport_id, airport_name;

ALTER TABLE airport
    ADD CONSTRAINT chk_airport_name_length
    CHECK (LENGTH(airport_name) >= 10);

INSERT INTO airport (airport_name, country, state, city, created_at, updated_at)
VALUES ('Short', 'Kazakhstan', 'Test', 'Test', now(), now());

-- Task 5

SELECT passport_number, COUNT(*) FROM passengers GROUP BY passport_number HAVING COUNT(*) > 1;

ALTER TABLE airline        ADD CONSTRAINT uq_airline_name           UNIQUE (airline_name);
ALTER TABLE airport        ADD CONSTRAINT uq_airport_name           UNIQUE (airport_name);
ALTER TABLE passengers     ADD CONSTRAINT uq_passenger_passport     UNIQUE (passport_number);
ALTER TABLE flights        ADD CONSTRAINT uq_flight_airline_no_time UNIQUE (airline_id, flight_no, sch_departure_time);
ALTER TABLE booking        ADD CONSTRAINT uq_booking_flight_passenger UNIQUE (flight_id, passenger_id);
ALTER TABLE booking_flight ADD CONSTRAINT uq_booking_flight         UNIQUE (flight_id, booking_id);
ALTER TABLE boarding_pass  ADD CONSTRAINT uq_boarding_pass_booking  UNIQUE (booking_id);
ALTER TABLE baggage        ADD CONSTRAINT uq_baggage_booking_time   UNIQUE (booking_id, created_at);
ALTER TABLE baggage_check  ADD CONSTRAINT uq_baggage_check_time     UNIQUE (booking_id, created_at);
ALTER TABLE security_check ADD CONSTRAINT uq_security_check_time    UNIQUE (passenger_id, created_at);

SELECT conrelid::regclass AS table_name, conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE contype = 'u' AND connamespace = 'public'::regnamespace
ORDER BY 1;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Copy', 'Cat', '1990-01-01', 'Male', 'Kazakhstan', 'Kazakhstan', 'N0000001', now(), now());

-- Task 6

ALTER TABLE passengers
    ADD CONSTRAINT chk_passenger_age_by_gender
    CHECK (
        (gender = 'Male'   AND date_of_birth <= CURRENT_DATE - INTERVAL '18 years') OR
        (gender = 'Female' AND date_of_birth <= CURRENT_DATE - INTERVAL '19 years') OR
        (gender NOT IN ('Male', 'Female'))
    ) NOT VALID;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Test', 'Girl', CURRENT_DATE - INTERVAL '18 years', 'Female', 'Kazakhstan',
        'Kazakhstan', 'TEST0002', now(), now());

-- Task 7

ALTER TABLE passengers
    ADD CONSTRAINT chk_passenger_age_by_country
    CHECK (
        date_of_birth <= CURRENT_DATE - CASE country_of_citizenship
                                            WHEN 'Kazakhstan' THEN INTERVAL '18 years'
                                            WHEN 'France'     THEN INTERVAL '17 years'
                                            ELSE                   INTERVAL '19 years'
                                        END
    ) NOT VALID;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Test', 'Japan', CURRENT_DATE - INTERVAL '18 years 6 months', 'Male', 'Japan',
        'Japan', 'TEST0003', now(), now());

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Aidos', 'Valid', CURRENT_DATE - INTERVAL '30 years', 'Male', 'Kazakhstan',
        'Kazakhstan', 'TEST0004', now(), now())
RETURNING passenger_id, first_name, date_of_birth;

-- Task 8

ALTER TABLE booking ADD COLUMN ticket_discount DECIMAL(7,2);

UPDATE booking
SET ticket_discount = ROUND(ticket_price * CASE WHEN created_at >= '2024-01-01' THEN 0.05 ELSE 0.10 END, 2);

ALTER TABLE booking
    ADD CONSTRAINT chk_ticket_discount
    CHECK (ticket_discount = ROUND(ticket_price * CASE WHEN created_at >= '2024-01-01'
                                                        THEN 0.05 ELSE 0.10 END, 2));

SELECT booking_id, created_at, ticket_price, ticket_discount,
       ticket_price - ticket_discount AS price_after_discount
FROM booking ORDER BY created_at LIMIT 15;

UPDATE booking SET ticket_discount = 0 WHERE booking_id = (SELECT MAX(booking_id) FROM booking);

-- Task 9

ALTER TABLE booking ALTER COLUMN status SET DEFAULT 'Confirmed';

INSERT INTO booking (flight_id, passenger_id, booking_platform, created_at, updated_at,
                     ticket_price, ticket_discount)
VALUES ((SELECT MAX(flight_id) FROM flights), 190, 'Website', now(), now(), 25000, 1250)
RETURNING booking_id, status, ticket_price, ticket_discount;

-- Task 10

ALTER TABLE airline        ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE airport        ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE passengers     ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE flights        ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE booking        ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE booking_flight ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE boarding_pass  ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE baggage        ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE baggage_check  ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE security_check ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP, ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

INSERT INTO security_check (check_result, passenger_id)
VALUES ('Passed', 1)
RETURNING *;
