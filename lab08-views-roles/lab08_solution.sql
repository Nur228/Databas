-- Task 1

CREATE VIEW v_flights_on_date AS
SELECT f.flight_id, f.flight_no, al.airline_name,
       dep.city AS from_city, arr.city AS to_city,
       f.sch_departure_time, f.sch_arrival_time, f.status
FROM flights f
JOIN airline al  ON al.airline_id  = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE f.sch_departure_time::date = CURRENT_DATE + 1;

SELECT * FROM v_flights_on_date;

-- Task 2

CREATE VIEW v_bookings_next_week AS
SELECT b.booking_id, p.first_name || ' ' || p.last_name AS passenger,
       f.flight_no, f.sch_departure_time, b.ticket_price, b.status
FROM booking b
JOIN flights f    ON f.flight_id    = b.flight_id
JOIN passengers p ON p.passenger_id = b.passenger_id
WHERE f.sch_departure_time BETWEEN now() AND now() + INTERVAL '7 days';

SELECT * FROM v_bookings_next_week ORDER BY sch_departure_time;

-- Task 3

CREATE VIEW v_top5_routes AS
SELECT dep.city AS from_city, arr.city AS to_city, COUNT(b.booking_id) AS bookings
FROM booking b
JOIN flights f   ON f.flight_id    = b.flight_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
GROUP BY dep.city, arr.city
ORDER BY bookings DESC
LIMIT 5;

SELECT * FROM v_top5_routes;

-- Task 4

CREATE VIEW v_airline_flights AS
SELECT f.flight_id, f.flight_no, al.airline_name, f.sch_departure_time, f.status
FROM flights f
JOIN airline al ON al.airline_id = f.airline_id
WHERE al.airline_name = 'Air Astana';

SELECT * FROM v_airline_flights ORDER BY sch_departure_time DESC LIMIT 20;

-- Task 5

CREATE OR REPLACE VIEW v_airline_flights AS
SELECT f.flight_id, f.flight_no, al.airline_name, f.sch_departure_time, f.status
FROM flights f
JOIN airline al ON al.airline_id = f.airline_id
WHERE al.airline_name = 'Air Astana'
  AND f.sch_departure_time BETWEEN now() AND now() + INTERVAL '7 days';

SELECT * FROM v_airline_flights ORDER BY sch_departure_time;

-- Task 6

CREATE VIEW v_delayed_24h AS
SELECT flight_id, flight_no, sch_departure_time, act_departure_time,
       act_departure_time - sch_departure_time AS delay
FROM flights
WHERE act_departure_time - sch_departure_time > INTERVAL '24 hours';

SELECT * FROM v_delayed_24h ORDER BY delay DESC;

-- Task 7

CREATE VIEW v_leffler_passengers AS
SELECT DISTINCT p.first_name || ' ' || p.last_name AS full_name,
       p.country_of_citizenship AS country
FROM passengers p
JOIN booking b ON b.passenger_id = p.passenger_id
WHERE b.booking_platform = 'Leffler-Thompson';

SELECT * FROM v_leffler_passengers ORDER BY full_name;

-- Task 8

CREATE VIEW v_top10_countries AS
SELECT arr.country, COUNT(*) AS visits
FROM booking b
JOIN flights f   ON f.flight_id    = b.flight_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
GROUP BY arr.country
ORDER BY visits DESC
LIMIT 10;

SELECT * FROM v_top10_countries;

-- Task 9

CREATE OR REPLACE VIEW v_leffler_passengers AS
SELECT DISTINCT p.first_name || ' ' || p.last_name AS full_name,
       p.country_of_citizenship AS country,
       p.passport_number
FROM passengers p
JOIN booking b ON b.passenger_id = p.passenger_id
WHERE b.booking_platform = 'Leffler-Thompson';

SELECT * FROM v_leffler_passengers ORDER BY full_name;

CREATE VIEW v_airline_simple AS
SELECT airline_id, airline_code, airline_name, airline_country
FROM airline;

INSERT INTO v_airline_simple (airline_code, airline_name, airline_country)
VALUES ('VWA', 'View Airways', 'KAZAKHSTAN')
RETURNING *;

SELECT * FROM airline WHERE airline_name = 'View Airways';

-- Task 10

SELECT table_name FROM information_schema.views WHERE table_schema = 'public';

DROP VIEW IF EXISTS v_flights_on_date, v_bookings_next_week, v_top5_routes,
                    v_airline_flights, v_delayed_24h, v_leffler_passengers,
                    v_top10_countries, v_airline_simple;

SELECT table_name FROM information_schema.views WHERE table_schema = 'public';

-- Task 11

CREATE ROLE flight_manager NOLOGIN;
CREATE ROLE flight_analyst NOLOGIN;

SELECT rolname, rolcanlogin, rolconnlimit
FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%'
ORDER BY rolname;

-- Task 12

CREATE ROLE first_user  LOGIN PASSWORD 'first123';
CREATE ROLE second_user LOGIN PASSWORD 'second123';

GRANT flight_manager TO first_user;
GRANT flight_analyst TO second_user;

SELECT r.rolname AS user_name, g.rolname AS group_name
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
WHERE r.rolname IN ('first_user', 'second_user');

-- Task 13

GRANT SELECT ON flights, airline, booking TO flight_analyst;

-- Task 14

GRANT SELECT, INSERT, UPDATE ON booking TO flight_manager;
GRANT SELECT ON airline, airport, flights, passengers, booking_flight,
                boarding_pass, baggage, baggage_check, security_check
      TO flight_manager;

SELECT grantee, table_name, string_agg(privilege_type, ', ') AS privileges
FROM information_schema.role_table_grants
WHERE grantee IN ('flight_manager', 'flight_analyst')
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

-- Task 15

SET ROLE second_user;
SELECT current_user;

SELECT flight_id, flight_no, status FROM flights LIMIT 5;

DELETE FROM booking WHERE booking_id = 1;

RESET ROLE;

-- Task 16

SET ROLE first_user;
SELECT current_user;

INSERT INTO booking (flight_id, passenger_id, booking_platform, ticket_price, ticket_discount)
VALUES ((SELECT MAX(flight_id) FROM flights), 1, 'Website', 20000, 1000)
RETURNING booking_id, flight_id, passenger_id, status, ticket_price;

UPDATE booking
SET booking_platform = 'Mobile App', updated_at = now()
WHERE booking_id = (SELECT MAX(booking_id) FROM booking)
RETURNING booking_id, booking_platform;

DELETE FROM booking WHERE booking_id = (SELECT MAX(booking_id) FROM booking);

RESET ROLE;

-- Task 17

GRANT SELECT (first_name, last_name, country_of_citizenship) ON passengers TO flight_analyst;

SET ROLE second_user;
SELECT first_name, last_name, country_of_citizenship FROM passengers LIMIT 5;

SELECT * FROM passengers LIMIT 5;

RESET ROLE;

-- Task 18

REVOKE SELECT ON booking FROM flight_analyst;

SET ROLE second_user;

SELECT * FROM booking LIMIT 5;
RESET ROLE;

-- Task 19

ALTER ROLE first_user PASSWORD 'newFirst456';
ALTER ROLE first_user CONNECTION LIMIT 3;
ALTER ROLE second_user RENAME TO analyst_user;

SELECT rolname, rolcanlogin, rolconnlimit
FROM pg_roles
WHERE rolname IN ('first_user', 'analyst_user', 'flight_manager', 'flight_analyst');

-- Task 20

DROP OWNED BY first_user, analyst_user, flight_manager, flight_analyst;
DROP ROLE first_user, analyst_user, flight_manager, flight_analyst;

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg\_%';
