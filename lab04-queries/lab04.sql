-- Task 1

SELECT airline_id, UPPER(airline_name) AS airline_name_upper
FROM airline;

-- Task 2

SELECT airline_name,
       REPLACE(airline_name, 'Air', 'Aero') AS new_name
FROM airline
WHERE airline_name LIKE '%Air%';

-- Task 3

SELECT flight_no FROM flights WHERE airline_id = 1
INTERSECT
SELECT flight_no FROM flights WHERE airline_id = 2;

-- Task 4

SELECT airport_id, airport_name, city, country
FROM airport
WHERE airport_name ILIKE '%Regional%'
  AND airport_name ILIKE '%Air%';

-- Task 5

SELECT first_name, last_name,
       TO_CHAR(date_of_birth, 'FMMonth DD, YYYY') AS birth_date
FROM passengers;

-- Task 6

SELECT DISTINCT flight_no
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY flight_no;

-- Task 7

SELECT flight_id, flight_no,
       sch_arrival_time, act_arrival_time,
       act_arrival_time - sch_arrival_time AS delay
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY delay DESC;

-- Task 8

SELECT airline_id, airline_name, airline_country, created_at
FROM airline
WHERE UPPER(airline_country) IN ('FRANCE', 'PORTUGAL', 'POLAND')
  AND created_at BETWEEN '2023-11-01' AND '2024-03-31 23:59:59';

-- Task 9

SELECT baggage_id, booking_id, weight_in_kg
FROM baggage
WHERE weight_in_kg > 25
ORDER BY weight_in_kg DESC
LIMIT 3;

-- Task 10

SELECT first_name || ' ' || last_name AS full_name, date_of_birth
FROM passengers
WHERE date_of_birth = (SELECT MAX(date_of_birth) FROM passengers);

-- Task 11

SELECT booking_platform, MIN(ticket_price) AS cheapest_price
FROM booking
GROUP BY booking_platform
ORDER BY cheapest_price;

-- Task 12

SELECT airline_id, airline_code, airline_name
FROM airline
WHERE airline_code ~ '[0-9]';

-- Task 13

SELECT airline_id, airline_name, created_at
FROM airline
ORDER BY created_at DESC
LIMIT 5;

-- Task 14

SELECT *
FROM baggage_check
WHERE booking_id BETWEEN 200 AND 300
  AND check_result <> 'Checked'
ORDER BY booking_id;

-- Task 15

SELECT baggage_check_id, created_at, updated_at
FROM baggage_check
WHERE date_trunc('month', updated_at) = date_trunc('month', created_at)
  AND updated_at < created_at;
