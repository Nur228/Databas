DROP TABLE IF EXISTS baggage_check, baggage, boarding_pass, booking_flight,
                     booking, security_check, flights, passengers,
                     airport, airline, airline_info CASCADE;

-- Task 1

CREATE TABLE airline_info (
    airline_id      INT,
    airline_code    VARCHAR(30),
    airline_name    VARCHAR(50),
    airline_country VARCHAR(50),
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    info            VARCHAR(50)
);

CREATE TABLE airport (
    airport_id   INT,
    airport_name VARCHAR(50),
    country      VARCHAR(50),
    state        VARCHAR(50),
    city         VARCHAR(50),
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP
);

CREATE TABLE baggage_check (
    baggage_check_id INT,
    check_result     VARCHAR(50),
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    booking_id       INT,
    passenger_id     INT
);

CREATE TABLE baggage (
    baggage_id   INT,
    weight_in_kg DECIMAL(4,2),
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP,
    booking_id   INT
);

CREATE TABLE boarding_pass (
    boarding_pass_id INT,
    booking_id       INT,
    seat             VARCHAR(50),
    boarding_time    TIMESTAMP,
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP
);

CREATE TABLE booking_flight (
    booking_flight_id INT,
    booking_id        INT,
    flight_id         INT,
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP
);

CREATE TABLE booking (
    booking_id       INT,
    flight_id        INT,
    passenger_id     INT,
    booking_platform VARCHAR(50),
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    status           VARCHAR(50),
    price            DECIMAL(7,2)
);

CREATE TABLE flights (
    flight_id            INT,
    sch_departure_time   TIMESTAMP,
    sch_arrival_time     TIMESTAMP,
    departing_airport_id INT,
    arriving_airport_id  INT,
    departing_gate       VARCHAR(50),
    arriving_gate        VARCHAR(50),
    airline_id           INT,
    act_departure_time   TIMESTAMP,
    act_arrival_time     TIMESTAMP,
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP
);

CREATE TABLE passengers (
    passenger_id           INT,
    first_name             VARCHAR(50),
    last_name              VARCHAR(50),
    date_of_birth          DATE,
    gender                 VARCHAR(50),
    country_of_citizenship VARCHAR(50),
    country_of_residence   VARCHAR(50),
    passport_number        VARCHAR(20),
    created_at             TIMESTAMP,
    updated_at             TIMESTAMP
);

CREATE TABLE security_check (
    security_check_id INT,
    check_result      VARCHAR(20),
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    passenger_id      INT
);

-- Task 2

ALTER TABLE airline_info   ADD PRIMARY KEY (airline_id);
ALTER TABLE airport        ADD PRIMARY KEY (airport_id);
ALTER TABLE baggage_check  ADD PRIMARY KEY (baggage_check_id);
ALTER TABLE baggage        ADD PRIMARY KEY (baggage_id);
ALTER TABLE boarding_pass  ADD PRIMARY KEY (boarding_pass_id);
ALTER TABLE booking_flight ADD PRIMARY KEY (booking_flight_id);
ALTER TABLE booking        ADD PRIMARY KEY (booking_id);
ALTER TABLE flights        ADD PRIMARY KEY (flight_id);
ALTER TABLE passengers     ADD PRIMARY KEY (passenger_id);
ALTER TABLE security_check ADD PRIMARY KEY (security_check_id);

-- Task 4

ALTER TABLE airline_info
    ALTER COLUMN airline_code    SET NOT NULL,
    ALTER COLUMN airline_name    SET NOT NULL,
    ALTER COLUMN airline_country SET NOT NULL,
    ALTER COLUMN created_at      SET NOT NULL,
    ALTER COLUMN updated_at      SET NOT NULL,
    ALTER COLUMN info            SET NOT NULL;

ALTER TABLE airport
    ALTER COLUMN airport_name SET NOT NULL,
    ALTER COLUMN country      SET NOT NULL,
    ALTER COLUMN state        SET NOT NULL,
    ALTER COLUMN city         SET NOT NULL,
    ALTER COLUMN created_at   SET NOT NULL,
    ALTER COLUMN updated_at   SET NOT NULL;

ALTER TABLE baggage_check
    ALTER COLUMN check_result SET NOT NULL,
    ALTER COLUMN created_at   SET NOT NULL,
    ALTER COLUMN updated_at   SET NOT NULL,
    ALTER COLUMN booking_id   SET NOT NULL,
    ALTER COLUMN passenger_id SET NOT NULL;

ALTER TABLE baggage
    ALTER COLUMN weight_in_kg SET NOT NULL,
    ALTER COLUMN created_at   SET NOT NULL,
    ALTER COLUMN updated_at   SET NOT NULL,
    ALTER COLUMN booking_id   SET NOT NULL;

ALTER TABLE boarding_pass
    ALTER COLUMN booking_id    SET NOT NULL,
    ALTER COLUMN seat          SET NOT NULL,
    ALTER COLUMN boarding_time SET NOT NULL,
    ALTER COLUMN created_at    SET NOT NULL,
    ALTER COLUMN updated_at    SET NOT NULL;

ALTER TABLE booking_flight
    ALTER COLUMN booking_id SET NOT NULL,
    ALTER COLUMN flight_id  SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

ALTER TABLE booking
    ALTER COLUMN flight_id        SET NOT NULL,
    ALTER COLUMN passenger_id     SET NOT NULL,
    ALTER COLUMN booking_platform SET NOT NULL,
    ALTER COLUMN created_at       SET NOT NULL,
    ALTER COLUMN updated_at       SET NOT NULL,
    ALTER COLUMN status           SET NOT NULL,
    ALTER COLUMN price            SET NOT NULL;

ALTER TABLE flights
    ALTER COLUMN sch_departure_time   SET NOT NULL,
    ALTER COLUMN sch_arrival_time     SET NOT NULL,
    ALTER COLUMN departing_airport_id SET NOT NULL,
    ALTER COLUMN arriving_airport_id  SET NOT NULL,
    ALTER COLUMN departing_gate       SET NOT NULL,
    ALTER COLUMN arriving_gate        SET NOT NULL,
    ALTER COLUMN airline_id           SET NOT NULL,
    ALTER COLUMN act_departure_time   SET NOT NULL,
    ALTER COLUMN act_arrival_time     SET NOT NULL,
    ALTER COLUMN created_at           SET NOT NULL,
    ALTER COLUMN updated_at           SET NOT NULL;

ALTER TABLE passengers
    ALTER COLUMN first_name             SET NOT NULL,
    ALTER COLUMN last_name              SET NOT NULL,
    ALTER COLUMN date_of_birth          SET NOT NULL,
    ALTER COLUMN gender                 SET NOT NULL,
    ALTER COLUMN country_of_citizenship SET NOT NULL,
    ALTER COLUMN country_of_residence   SET NOT NULL,
    ALTER COLUMN passport_number        SET NOT NULL,
    ALTER COLUMN created_at             SET NOT NULL,
    ALTER COLUMN updated_at             SET NOT NULL;

ALTER TABLE security_check
    ALTER COLUMN check_result SET NOT NULL,
    ALTER COLUMN created_at   SET NOT NULL,
    ALTER COLUMN updated_at   SET NOT NULL,
    ALTER COLUMN passenger_id SET NOT NULL;

-- Task 5

ALTER TABLE airline_info RENAME TO airline;

-- Task 6

ALTER TABLE booking RENAME COLUMN price TO ticket_price;

-- Task 7

ALTER TABLE flights ALTER COLUMN departing_gate TYPE TEXT;

-- Task 8

ALTER TABLE airline DROP COLUMN info;

-- Task 9

ALTER TABLE security_check ADD CONSTRAINT fk_security_check_passenger
    FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id) ON DELETE CASCADE;
ALTER TABLE booking ADD CONSTRAINT fk_booking_passenger
    FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id) ON DELETE CASCADE;
ALTER TABLE baggage_check ADD CONSTRAINT fk_baggage_check_passenger
    FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id) ON DELETE CASCADE;

ALTER TABLE baggage_check ADD CONSTRAINT fk_baggage_check_booking
    FOREIGN KEY (booking_id) REFERENCES booking (booking_id) ON DELETE CASCADE;
ALTER TABLE baggage ADD CONSTRAINT fk_baggage_booking
    FOREIGN KEY (booking_id) REFERENCES booking (booking_id) ON DELETE CASCADE;
ALTER TABLE boarding_pass ADD CONSTRAINT fk_boarding_pass_booking
    FOREIGN KEY (booking_id) REFERENCES booking (booking_id) ON DELETE CASCADE;
ALTER TABLE booking_flight ADD CONSTRAINT fk_booking_flight_booking
    FOREIGN KEY (booking_id) REFERENCES booking (booking_id) ON DELETE CASCADE;

ALTER TABLE booking_flight ADD CONSTRAINT fk_booking_flight_flight
    FOREIGN KEY (flight_id) REFERENCES flights (flight_id) ON DELETE CASCADE;

ALTER TABLE flights ADD CONSTRAINT fk_flights_departing_airport
    FOREIGN KEY (departing_airport_id) REFERENCES airport (airport_id) ON DELETE CASCADE;
ALTER TABLE flights ADD CONSTRAINT fk_flights_arriving_airport
    FOREIGN KEY (arriving_airport_id) REFERENCES airport (airport_id) ON DELETE CASCADE;

ALTER TABLE flights ADD CONSTRAINT fk_flights_airline
    FOREIGN KEY (airline_id) REFERENCES airline (airline_id) ON DELETE CASCADE;

ALTER TABLE booking ADD CONSTRAINT fk_booking_flight
    FOREIGN KEY (flight_id) REFERENCES flights (flight_id) ON DELETE CASCADE;

SELECT conrelid::regclass AS table_name, conname AS constraint_name,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY 1, 2;
