SELECT setseed(0.7);

INSERT INTO airport (airport_name, country, state, city, created_at, updated_at)
SELECT chr(65 + floor(random()*26)::int) || substr(md5(i::text), 1, 6) || ' '
         || (ARRAY['International Airport','Airport','Regional Airport','Airfield'])[1 + floor(random()*4)::int]
         || ' ' || i,
       (ARRAY['Kazakhstan','Russia','China','USA','Germany','France','Turkey','Japan','Italy','Spain',
              'Poland','Portugal','Brazil','India','Canada','Mexico','Egypt','Kenya','Norway','Sweden',
              'Finland','Greece','Chile','Peru','Vietnam'])[1 + floor(random()*25)::int],
       'State ' || (i % 300),
       'City ' || (i % 2000),
       now() - random() * INTERVAL '1000 days',
       now()
FROM generate_series(1, 20000) i;

INSERT INTO passengers (first_name, last_name, date_of_birth, gender, country_of_citizenship,
                        country_of_residence, passport_number, created_at, updated_at)
SELECT (ARRAY['Aidar','Nursultan','Daniyar','Arman','John','Pierre','Kenji','Mehmet','Lukas','Carlos',
              'Aigerim','Dana','Madina','Aruzhan','Emma','Sophie','Yuki','Elif','Anna','Maria'])[1 + floor(random()*20)::int],
       (ARRAY['Seitov','Omarov','Nurlanov','Smith','Dubois','Tanaka','Yilmaz','Muller','Garcia','Kowalski',
              'Santos','Reyes','Kim','Ivanov','Brown','Lee','Wang','Silva','Rossi','Novak'])[1 + floor(random()*20)::int],
       DATE '1950-01-01' + floor(random() * 18250)::int,
       CASE WHEN random() < 0.5 THEN 'Male' ELSE 'Female' END,
       c, c,
       'B' || lpad(i::text, 8, '0'),
       now() - random() * INTERVAL '700 days',
       now()
FROM (SELECT i, (ARRAY['Kazakhstan','France','Philippines','USA','Germany','Japan','Turkey',
                       'United Kingdom','Poland','Portugal','China','India'])[1 + floor(random()*12)::int] AS c
      FROM generate_series(1, 100000) i) s;

WITH ap AS (SELECT array_agg(airport_id ORDER BY airport_id) ids FROM airport WHERE airport_id <= 30)
INSERT INTO flights (flight_no, sch_departure_time, sch_arrival_time, departing_airport_id, arriving_airport_id,
                     departing_gate, arriving_gate, airline_id, act_departure_time, act_arrival_time,
                     status, created_at, updated_at)
SELECT 'BX' || i,
       t, t + INTERVAL '3 hours',
       ap.ids[d], ap.ids[1 + (d + floor(random()*(n-1))::int) % n],
       'G' || (1 + i % 40), 'G' || (1 + (i * 7) % 40),
       1 + floor(random() * 24)::int,
       t + (random()*120) * INTERVAL '1 minute',
       t + INTERVAL '3 hours' + (random()*120 - 20) * INTERVAL '1 minute',
       CASE WHEN r < 0.85  THEN 'Departed'
            WHEN r < 0.95  THEN 'Arrived'
            WHEN r < 0.99  THEN 'Scheduled'
            WHEN r < 0.995 THEN 'Boarding'
            ELSE 'Cancelled' END,
       t - INTERVAL '60 days', t - INTERVAL '1 day'
FROM ap,
     LATERAL (SELECT cardinality(ap.ids) AS n) nn,
     LATERAL (SELECT i,
                     TIMESTAMP '2025-01-01' + i * INTERVAL '7 minutes' AS t,
                     1 + floor(random() * cardinality(ap.ids))::int    AS d,
                     random() AS r
              FROM generate_series(1, 100000) i) g;

INSERT INTO booking (flight_id, passenger_id, booking_platform, created_at, updated_at, status,
                     ticket_price, ticket_discount)
SELECT f.flight_id, p.passenger_id,
       (ARRAY['Website','Mobile App','Aviasales','Kayak','Expedia','Trip.com'])[1 + floor(random()*6)::int],
       ts, ts, 'Confirmed', price, ROUND(price * 0.05, 2)
FROM (SELECT passenger_id, row_number() OVER (ORDER BY passenger_id) AS k
      FROM passengers WHERE passport_number LIKE 'B%') p
CROSS JOIN (VALUES (0), (500)) shift(s)
JOIN (SELECT flight_id, row_number() OVER (ORDER BY flight_id) AS k
      FROM flights WHERE flight_no LIKE 'BX%') f
  ON f.k = ((p.k - 1 + shift.s) % 100000) + 1
CROSS JOIN LATERAL (SELECT round((1000 + random() * 49000)::numeric, 2) AS price,
                           TIMESTAMP '2025-01-01' + random() * INTERVAL '300 days' AS ts) x;

INSERT INTO booking_flight (booking_id, flight_id, created_at, updated_at)
SELECT b.booking_id, b.flight_id, b.created_at, b.updated_at
FROM booking b
WHERE NOT EXISTS (SELECT 1 FROM booking_flight bf WHERE bf.booking_id = b.booking_id);

INSERT INTO baggage (weight_in_kg, created_at, updated_at, booking_id)
SELECT round((1 + random() * 22)::numeric, 2),
       b.created_at + random() * INTERVAL '2 hours',
       b.created_at + INTERVAL '3 hours',
       b.booking_id
FROM booking b
WHERE b.booking_id % 2 = 0 AND b.booking_id > 400;

ANALYZE;

SELECT 'airport' AS table_name, count(*) FROM airport
UNION ALL SELECT 'passengers',     count(*) FROM passengers
UNION ALL SELECT 'flights',        count(*) FROM flights
UNION ALL SELECT 'booking',        count(*) FROM booking
UNION ALL SELECT 'booking_flight', count(*) FROM booking_flight
UNION ALL SELECT 'baggage',        count(*) FROM baggage;
