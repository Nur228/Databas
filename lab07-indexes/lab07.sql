-- Task 1

CREATE INDEX idx_flights_act_departure ON flights (act_departure_time);

-- Task 2

CREATE UNIQUE INDEX idx_flights_no_sch_departure ON flights (flight_no, sch_departure_time);

-- Task 3

CREATE INDEX idx_flights_dep_arr_airport ON flights (departing_airport_id, arriving_airport_id);

-- Task 4

DROP INDEX idx_flights_act_departure;

EXPLAIN ANALYZE
SELECT * FROM flights
WHERE act_departure_time BETWEEN '2025-06-01' AND '2025-06-02';

CREATE INDEX idx_flights_act_departure ON flights (act_departure_time);

EXPLAIN ANALYZE
SELECT * FROM flights
WHERE act_departure_time BETWEEN '2025-06-01' AND '2025-06-02';

-- Task 5

EXPLAIN ANALYZE
SELECT * FROM flights
WHERE departing_airport_id = 1 AND arriving_airport_id = 2;

-- Task 6

CREATE UNIQUE INDEX idx_passengers_passport ON passengers (passport_number);

SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'passengers' AND indexname = 'idx_passengers_passport';

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Alikhan', 'Bekov', '1995-04-12', 'Male', 'Kazakhstan', 'Kazakhstan', 'KZ7777777', now(), now())
RETURNING passenger_id, passport_number;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
VALUES ('Samat', 'Kairatov', '1993-09-01', 'Male', 'Kazakhstan', 'Kazakhstan', 'KZ7777777', now(), now());

-- Task 7

CREATE INDEX idx_passengers_name_dob_country
    ON passengers (first_name, last_name, date_of_birth, country_of_citizenship);

EXPLAIN ANALYZE
SELECT * FROM passengers
WHERE country_of_citizenship = 'Philippines'
  AND date_of_birth BETWEEN '1984-01-01' AND '1984-12-31';

EXPLAIN ANALYZE
SELECT * FROM passengers
WHERE first_name = 'Aidar' AND last_name = 'Seitov';

-- Task 8

SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'passengers';

DROP INDEX idx_passengers_passport;
DROP INDEX idx_passengers_name_dob_country;

SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'passengers';

-- Task 9

EXPLAIN ANALYZE SELECT * FROM booking WHERE passenger_id = 50000;

CREATE INDEX idx_booking_passenger ON booking (passenger_id);

EXPLAIN ANALYZE SELECT * FROM booking WHERE passenger_id = 50000;

-- Task 10

CREATE INDEX idx_booking_flight_booking_flight ON booking_flight (booking_id, flight_id);

EXPLAIN ANALYZE
SELECT f.flight_no, b.ticket_price
FROM booking b
JOIN booking_flight bf ON bf.booking_id = b.booking_id
JOIN flights f         ON f.flight_id   = bf.flight_id
WHERE b.ticket_price > 9000;

EXPLAIN ANALYZE
SELECT f.flight_no, b.ticket_price
FROM booking b
JOIN booking_flight bf ON bf.booking_id = b.booking_id
JOIN flights f         ON f.flight_id   = bf.flight_id
WHERE b.ticket_price > 49990;

-- Task 11

CREATE INDEX idx_flights_status ON flights (status);

SELECT status, COUNT(*), ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent
FROM flights GROUP BY status ORDER BY 2 DESC;

EXPLAIN ANALYZE SELECT * FROM flights WHERE status = 'Departed';
EXPLAIN ANALYZE SELECT * FROM flights WHERE status = 'Boarding';

-- Task 12

CREATE INDEX idx_baggage_weight ON baggage (weight_in_kg);

EXPLAIN ANALYZE SELECT * FROM baggage WHERE weight_in_kg > 49;
EXPLAIN ANALYZE SELECT * FROM baggage WHERE weight_in_kg > 5;

-- Task 13

CREATE INDEX idx_airport_name ON airport (airport_name);

EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE 'A%';
EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE '%Airport';

CREATE INDEX idx_airport_name_pattern ON airport (airport_name varchar_pattern_ops);

EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE 'A%';
EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE '%Airport';

-- Task 14

CREATE INDEX idx_airport_country_city ON airport (country, city);

EXPLAIN ANALYZE SELECT * FROM airport WHERE country = 'Kazakhstan';
EXPLAIN ANALYZE SELECT * FROM airport WHERE city = 'City 15';
EXPLAIN ANALYZE SELECT * FROM airport WHERE country = 'Kazakhstan' AND city = 'City 15';

-- Task 15

CREATE INDEX idx_passengers_lower_last_name ON passengers (LOWER(last_name));

EXPLAIN ANALYZE SELECT * FROM passengers WHERE LOWER(last_name) = 'irnis';
EXPLAIN ANALYZE SELECT * FROM passengers WHERE last_name = 'Irnis';

-- Task 16

CREATE INDEX idx_booking_passenger_price ON booking (passenger_id) INCLUDE (ticket_price);

VACUUM ANALYZE booking;

EXPLAIN ANALYZE SELECT ticket_price FROM booking WHERE passenger_id = 50000;

-- Task 17

CREATE UNIQUE INDEX idx_airline_code_unique ON airline (airline_code);

SELECT airline_code, COUNT(*) AS cnt, string_agg(airline_name, ', ') AS airlines
FROM airline
GROUP BY airline_code
HAVING COUNT(*) > 1;

CREATE UNIQUE INDEX idx_airline_code_unique ON airline (airline_code)
WHERE airline_code <> 'UNK';

SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'airline';
