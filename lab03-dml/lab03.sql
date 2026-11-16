-- Task 1

-- Task 2

INSERT INTO airline (airline_code, airline_name, airline_country, created_at, updated_at)
VALUES ('KZR', 'KazAir', 'Kazakhstan', now(), now())
RETURNING *;

-- Task 3

UPDATE airline
SET airline_country = 'Turkey',
    updated_at      = now()
WHERE airline_name = 'KazAir'
RETURNING *;

-- Task 4

INSERT INTO airline (airline_code, airline_name, airline_country, created_at, updated_at)
VALUES ('AEZ', 'AirEasy', 'France', now(), now()),
       ('FHI', 'FlyHigh', 'Brazil', now(), now()),
       ('FFY', 'FlyFly',  'Poland', now(), now())
RETURNING *;

-- Task 5

SELECT count(*) AS flights_to_delete
FROM flights
WHERE sch_arrival_time >= '2024-01-01' AND sch_arrival_time < '2025-01-01';

DELETE FROM flights
WHERE sch_arrival_time >= '2024-01-01' AND sch_arrival_time < '2025-01-01'
RETURNING flight_id, flight_no, sch_arrival_time;

-- Task 6

UPDATE booking
SET ticket_price = ticket_price * 1.15,
    updated_at   = now()
RETURNING booking_id, ticket_price;

-- Task 7

DELETE FROM booking
WHERE ticket_price < 10000
RETURNING booking_id, ticket_price;

-- Task 8

UPDATE airline
SET airline_code = 'UNK', updated_at = now()
WHERE airline_code IS NULL
RETURNING *;

ALTER TABLE airline ALTER COLUMN airline_code SET DEFAULT 'UNK';

-- Task 9

DELETE FROM baggage_check
WHERE created_at < '2023-06-01'
  AND check_result = 'Not checked'
RETURNING *;

-- Task 10

DELETE FROM airport
WHERE state IS NULL
  AND city IN ('Mlawe', 'Kepuh')
RETURNING *;

-- Task 11

INSERT INTO baggage_check (check_result, created_at, updated_at, booking_id, passenger_id)
SELECT 'Not checked', now(), now(), booking_id, passenger_id
FROM booking
ORDER BY booking_id
LIMIT 1
RETURNING baggage_check_id, created_at;

-- Task 12

UPDATE airline
SET airline_country = UPPER(airline_country)
RETURNING airline_id, airline_name, airline_country;

-- Task 13

UPDATE airline
SET airline_name    = 'Global Airways',
    airline_country = 'United Kingdom',
    updated_at      = CURRENT_DATE
WHERE airline_id = 5
RETURNING *;

-- Task 14

UPDATE airport
SET state = 'Capital District', updated_at = now()
WHERE city IN ('Astana', 'London', 'Tokyo')
RETURNING airport_id, airport_name, city, state;

-- Task 15

UPDATE baggage_check
SET check_result = 'Checked',
    updated_at   = now()
WHERE check_result = 'Not checked'
  AND created_at >= '2024-03-01'
  AND created_at <  '2024-04-01'
RETURNING *;
