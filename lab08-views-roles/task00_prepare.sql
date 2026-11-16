DELETE FROM flights WHERE flight_no LIKE 'UP%';

INSERT INTO flights (flight_no, sch_departure_time, sch_arrival_time, departing_airport_id,
                     arriving_airport_id, departing_gate, arriving_gate, airline_id,
                     act_departure_time, act_arrival_time, status, created_at, updated_at)
SELECT 'UP' || (100 + n),
       t, t + INTERVAL '3 hours',
       dep, arr,
       'A' || (1 + n % 20), 'B' || (1 + n % 20),
       1 + (n % 6),
       NULL, NULL, 'Scheduled', now(), now()
FROM (SELECT n,
             date_trunc('hour', now()) + INTERVAL '2 hours' + n * INTERVAL '8 hours' AS t,
             (ARRAY[1,2,3,5,7,9,10,11,12,13,14,17,19,23,24])[1 + n % 15]            AS dep,
             (ARRAY[2,1,9,10,5,14,7,1,2,3,24,19,23,17,12])[1 + (n * 7) % 15]       AS arr
      FROM generate_series(1, 40) n) s
WHERE dep <> arr;

INSERT INTO booking (flight_id, passenger_id, booking_platform, created_at, updated_at,
                     status, ticket_price, ticket_discount)
SELECT f.flight_id,
       p.passenger_id,
       (ARRAY['Website','Mobile App','Leffler-Thompson','Aviasales','Kayak'])[1 + (f.flight_id + k) % 5],
       now(), now(), 'Confirmed',
       price, ROUND(price * 0.05, 2)
FROM flights f
CROSS JOIN generate_series(1, 5) k
JOIN passengers p ON p.passport_number = 'B' || lpad(((f.flight_id * 5 + k) % 90000 + 1)::text, 8, '0')
CROSS JOIN LATERAL (SELECT (15000 + ((f.flight_id * 37 + k * 1013) % 30000))::numeric(7,2) AS price) x
WHERE f.flight_no LIKE 'UP%';

INSERT INTO booking_flight (booking_id, flight_id)
SELECT b.booking_id, b.flight_id
FROM booking b JOIN flights f ON f.flight_id = b.flight_id
WHERE f.flight_no LIKE 'UP%';

ANALYZE flights; ANALYZE booking;

SELECT f.flight_no, al.airline_name, f.sch_departure_time, COUNT(b.booking_id) AS bookings
FROM flights f
JOIN airline al ON al.airline_id = f.airline_id
LEFT JOIN booking b ON b.flight_id = f.flight_id
WHERE f.sch_departure_time BETWEEN now() AND now() + INTERVAL '7 days'
GROUP BY f.flight_id, f.flight_no, al.airline_name, f.sch_departure_time
ORDER BY f.sch_departure_time;
