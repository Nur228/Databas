-- Task 1

SELECT f.flight_id, f.flight_no, al.airline_name, f.sch_departure_time, f.status
FROM flights f
JOIN airline al ON al.airline_id = f.airline_id
WHERE al.airline_name = 'Air Astana'
ORDER BY f.sch_departure_time;

-- Task 2

SELECT f.flight_id, f.flight_no, dep.airport_name AS departure_airport, f.sch_departure_time
FROM flights f
JOIN airport dep ON dep.airport_id = f.departing_airport_id
ORDER BY f.flight_id;

-- Task 3

SELECT al.airline_id, al.airline_name
FROM airline al
LEFT JOIN flights f
       ON f.airline_id = al.airline_id
      AND f.sch_departure_time >= date_trunc('month', CURRENT_DATE) + INTERVAL '1 month'
      AND f.sch_departure_time <  date_trunc('month', CURRENT_DATE) + INTERVAL '2 months'
WHERE f.flight_id IS NULL
ORDER BY al.airline_id;

-- Task 4

SELECT f.flight_no, p.first_name, p.last_name, p.passport_number, b.status
FROM booking b
JOIN passengers p ON p.passenger_id = b.passenger_id
JOIN flights f    ON f.flight_id    = b.flight_id
WHERE b.flight_id = (SELECT flight_id FROM booking
                     GROUP BY flight_id ORDER BY COUNT(*) DESC, flight_id LIMIT 1);

-- Task 5

SELECT f.flight_id, f.flight_no,
       ROUND(AVG(b.ticket_price), 2) AS avg_price,
       SUM(b.ticket_price)           AS total_price,
       MAX(b.ticket_price)           AS max_price,
       MIN(b.ticket_price)           AS min_price,
       COUNT(*)                      AS bookings
FROM flights f
JOIN booking b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_no
ORDER BY f.flight_id;

-- Task 6

SELECT f.flight_no, al.airline_name,
       dep.city AS from_city, arr.city AS to_city, arr.country AS to_country,
       f.sch_departure_time
FROM flights f
JOIN airline al  ON al.airline_id  = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE arr.country = 'Kazakhstan'
ORDER BY f.sch_departure_time;

-- Task 7

SELECT p.first_name, p.last_name, p.date_of_birth,
       EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS age,
       arr.city AS destination_city, arr.country AS destination_country
FROM passengers p
JOIN booking b   ON b.passenger_id = p.passenger_id
JOIN flights f   ON f.flight_id    = b.flight_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
WHERE AGE(p.date_of_birth) < INTERVAL '18 years'
ORDER BY age;

-- Task 8

SELECT p.first_name || ' ' || p.last_name AS full_name,
       p.passport_number,
       arr.city AS destination,
       COALESCE(f.act_arrival_time, f.sch_arrival_time) AS arrival_time,
       CASE WHEN f.act_arrival_time IS NULL THEN 'scheduled' ELSE 'actual' END AS time_type
FROM passengers p
JOIN booking b   ON b.passenger_id = p.passenger_id
JOIN flights f   ON f.flight_id    = b.flight_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
ORDER BY arrival_time DESC;

-- Task 9

SELECT dep.country                              AS airport_country,
       COUNT(*)                                 AS flights_count,
       string_agg(f.flight_no, ', ' ORDER BY f.flight_no) AS flights
FROM flights f
JOIN airline al  ON al.airline_id  = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
WHERE UPPER(al.airline_country) = UPPER(dep.country)
GROUP BY dep.country
ORDER BY flights_count DESC;

-- Task 10

SELECT f.flight_no, al.airline_name,
       dep.airport_name AS departure_airport,
       arr.airport_name AS arrival_airport
FROM flights f
JOIN airline al  ON al.airline_id  = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
JOIN airport arr ON arr.airport_id = f.arriving_airport_id
ORDER BY f.flight_no;

-- Task 11

SELECT p.first_name || ' ' || p.last_name AS full_name, f.flight_no, al.airline_name
FROM passengers p
JOIN booking b  ON b.passenger_id = p.passenger_id
JOIN flights f  ON f.flight_id    = b.flight_id
JOIN airline al ON al.airline_id  = f.airline_id
WHERE al.airline_name = 'Turkish Airlines'
ORDER BY full_name;

-- Task 12

SELECT f.flight_id, f.flight_no, arr.country AS destination_country,
       COUNT(b.booking_id) AS passengers_booked
FROM flights f
JOIN airport arr     ON arr.airport_id = f.arriving_airport_id
LEFT JOIN booking b  ON b.flight_id    = f.flight_id
GROUP BY f.flight_id, f.flight_no, arr.country
ORDER BY passengers_booked, f.flight_id;

-- Task 13

SELECT p.passenger_id, p.first_name, p.last_name
FROM passengers p
LEFT JOIN booking b ON b.passenger_id = p.passenger_id
WHERE b.booking_id IS NULL
ORDER BY p.passenger_id;

-- Task 14

SELECT al.airline_id, al.airline_name, COUNT(f.flight_id) AS flights_count
FROM airline al
LEFT JOIN flights f ON f.airline_id = al.airline_id
GROUP BY al.airline_id, al.airline_name
ORDER BY flights_count DESC, al.airline_id;

-- Task 15

SELECT al.airline_name, f.flight_no, dep.city AS departure_city, f.sch_departure_time
FROM flights f
JOIN airline al  ON al.airline_id  = f.airline_id
JOIN airport dep ON dep.airport_id = f.departing_airport_id
WHERE dep.country = 'Kazakhstan'
ORDER BY f.sch_departure_time;
