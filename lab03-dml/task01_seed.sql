SELECT setseed(0.42);

TRUNCATE baggage_check, baggage, boarding_pass, booking_flight, booking,
         security_check, flights, passengers, airport, airline RESTART IDENTITY CASCADE;

INSERT INTO airline (airline_code, airline_name, airline_country, created_at, updated_at) VALUES
 ('KC',  'Air Astana',          'Kazakhstan',           '2022-03-14 10:00', '2023-05-01 12:00'),
 ('DV',  'SCAT Airlines',       'Kazakhstan',           '2022-06-02 09:30', '2023-02-11 08:00'),
 ('TK',  'Turkish Airlines',    'Turkey',               '2022-01-20 14:15', '2024-01-10 10:00'),
 ('AF',  'Air France',          'France',               '2023-12-05 11:00', '2024-02-01 16:20'),
 ('LH',  'Lufthansa',           'Germany',              '2022-09-09 07:45', '2023-09-09 07:45'),
 ('BA',  'British Airways',     'United Kingdom',       '2022-04-18 13:00', '2023-04-18 13:00'),
 ('TP',  'TAP Air Portugal',    'Portugal',             '2024-02-14 15:30', '2024-06-01 09:00'),
 ('LO',  'LOT Polish Airlines', 'Poland',               '2022-11-23 10:10', '2023-01-15 10:10'),
 ('JL',  'Japan Airlines',      'Japan',                '2023-03-03 03:03', '2023-08-08 08:08'),
 ('EK',  'Emirates',            'United Arab Emirates', '2022-02-02 02:02', '2024-05-05 05:05'),
 ('S7',  'S7 Airlines',         'Russia',               '2023-07-07 07:07', '2023-12-12 12:12'),
 ('U6',  'Ural Airlines',       'Russia',               '2024-08-19 18:00', '2024-09-01 10:00'),
 ('FZ',  'flydubai',            'United Arab Emirates', '2024-10-10 10:10', '2025-01-01 00:00'),
 ('5N',  'Smartavia',           'Russia',               '2025-01-22 11:11', '2025-03-03 12:00'),
 (NULL,  'Air Lituanica',       'Lithuania',            '2023-01-30 16:40', '2023-03-30 16:40'),
 (NULL,  'Qazaq Air',           'Kazakhstan',           '2025-04-04 09:00', '2025-05-05 09:00'),
 ('G9',  'Air Arabia',          'United Arab Emirates', '2023-05-15 12:00', '2023-06-15 12:00'),
 ('PC',  'Pegasus Airlines',    'Turkey',               '2024-11-11 11:00', '2025-02-02 11:00'),
 ('TO',  'Transavia France',    'France',               '2023-11-20 08:20', '2024-01-20 08:20'),
 ('ENT', 'Enter Air',           'Poland',               '2024-03-20 19:00', '2024-04-20 19:00');

INSERT INTO airport (airport_name, country, state, city, created_at, updated_at) VALUES
 ('Almaty International Airport',          'Kazakhstan',     'Almaty Region',     'Almaty',           '2022-01-01', '2023-01-01'),
 ('Nursultan Nazarbayev Intl Airport',     'Kazakhstan',     'Akmola Region',     'Astana',           '2022-01-01', '2023-01-01'),
 ('Shymkent International Airport',        'Kazakhstan',     'Turkistan Region',  'Shymkent',         '2022-01-02', '2023-01-02'),
 ('Aktau Airport',                         'Kazakhstan',     'Mangystau Region',  'Aktau',            '2022-01-03', '2023-01-03'),
 ('Heathrow Airport',                      'United Kingdom', 'England',           'London',           '2022-01-04', '2023-01-04'),
 ('Gatwick Airport',                       'United Kingdom', 'England',           'London',           '2022-01-05', '2023-01-05'),
 ('Haneda Airport',                        'Japan',          'Tokyo Metropolis',  'Tokyo',            '2022-01-06', '2023-01-06'),
 ('Narita International Airport',          'Japan',          'Chiba',             'Tokyo',            '2022-01-07', '2023-01-07'),
 ('Istanbul Airport',                      'Turkey',         'Istanbul Province', 'Istanbul',         '2022-01-08', '2023-01-08'),
 ('Charles de Gaulle Airport',             'France',         'Ile-de-France',     'Paris',            '2022-01-09', '2023-01-09'),
 ('Lisbon Humberto Delgado Airport',       'Portugal',       'Lisbon District',   'Lisbon',           '2022-01-10', '2023-01-10'),
 ('Warsaw Chopin Airport',                 'Poland',         'Masovian',          'Warsaw',           '2022-01-11', '2023-01-11'),
 ('Frankfurt Airport',                     'Germany',        'Hesse',             'Frankfurt',        '2022-01-12', '2023-01-12'),
 ('Dubai International Airport',           'United Arab Emirates', 'Dubai',       'Dubai',            '2022-01-13', '2023-01-13'),
 ('Mlawe Regional Air Strip',              'Poland',         NULL,                'Mlawe',            '2022-01-14', '2023-01-14'),
 ('Kepuh Air Regional Field',              'Indonesia',      NULL,                'Kepuh',            '2022-01-15', '2023-01-15'),
 ('Ninoy Aquino International Airport',    'Philippines',    'Metro Manila',      'Manila',           '2022-01-16', '2023-01-16'),
 ('Mactan Regional Air Terminal',          'Philippines',    'Cebu',              'Cebu',             '2022-01-17', '2023-01-17'),
 ('John F. Kennedy International Airport', 'USA',            'New York',          'New York',         '2022-01-18', '2023-01-18'),
 ('Los Angeles International Airport',     'USA',            'California',        'Los Angeles',      '2022-01-19', '2023-01-19'),
 ('Kostanay Regional Airport',             'Kazakhstan',     'Kostanay Region',   'Kostanay',         '2022-01-20', '2023-01-20'),
 ('Karaganda Regional Air Base',           'Kazakhstan',     'Karaganda Region',  'Karaganda',        '2022-01-21', '2023-01-21'),
 ('Beijing Capital International Airport', 'China',          'Beijing',           'Beijing',          '2022-01-22', '2023-01-22'),
 ('Incheon International Airport',         'South Korea',    'Incheon',           'Seoul',            '2022-01-23', '2023-01-23'),
 ('Tashkent International Airport',        'Uzbekistan',     'Tashkent',          'Tashkent',         '2022-01-24', '2023-01-24'),
 ('Rome Fiumicino Airport',                'Italy',          'Lazio',             'Rome',             '2022-01-25', '2023-01-25'),
 ('Madrid Barajas Airport',                'Spain',          'Madrid',            'Madrid',           '2022-01-26', '2023-01-26'),
 ('Pulkovo',                               'Russia',         'Leningrad Oblast',  'Saint Petersburg', '2022-01-27', '2023-01-27'),
 ('Vnukovo',                               'Russia',         'Moscow Oblast',     'Moscow',           '2022-01-28', '2023-01-28'),
 ('Astana Air Terminal',                   'Kazakhstan',     NULL,                'Astana',           '2022-01-29', '2023-01-29');

INSERT INTO passengers (first_name, last_name, date_of_birth, gender,
                        country_of_citizenship, country_of_residence,
                        passport_number, created_at, updated_at)
SELECT
    CASE WHEN g = 'Male'
         THEN (ARRAY['Aidar','Nursultan','Daniyar','Arman','John','Pierre','Kenji','Mehmet','Lukas','Carlos','Marek','Jose'])[1 + floor(random()*12)::int]
         ELSE (ARRAY['Aigerim','Dana','Madina','Aruzhan','Emma','Sophie','Yuki','Elif','Anna','Maria','Zofia','Ana'])[1 + floor(random()*12)::int]
    END,
    (ARRAY['Seitov','Omarov','Nurlanov','Smith','Dubois','Tanaka','Yilmaz','Muller','Garcia','Kowalski','Santos','Reyes','Kim','Ivanov','Brown'])[1 + floor(random()*15)::int],
    DATE '1950-01-01' + floor(random() * 25500)::int,
    g,
    c,
    CASE WHEN random() < 0.8 THEN c
         ELSE (ARRAY['Kazakhstan','France','United Kingdom','USA','Germany','Turkey'])[1 + floor(random()*6)::int] END,
    'N' || lpad(i::text, 7, '0'),
    ts,
    ts + random() * INTERVAL '200 days'
FROM (
    SELECT i,
           CASE WHEN random() < 0.5 THEN 'Male' ELSE 'Female' END AS g,
           (ARRAY['Kazakhstan','Kazakhstan','Kazakhstan','France','Philippines','USA','Germany',
                  'Japan','Turkey','United Kingdom','Poland','Portugal','China'])[1 + floor(random()*13)::int] AS c,
           TIMESTAMP '2022-01-01' + random() * INTERVAL '900 days' AS ts
    FROM generate_series(1, 200) AS i
) s;

UPDATE passengers SET last_name = 'Irnis'                                    WHERE passenger_id IN (42, 142);
UPDATE passengers SET country_of_citizenship = 'Philippines',
                      date_of_birth = DATE '1984-01-01' + passenger_id       WHERE passenger_id IN (17, 57, 117);

INSERT INTO flights (flight_no, sch_departure_time, sch_arrival_time,
                     departing_airport_id, arriving_airport_id,
                     departing_gate, arriving_gate, airline_id,
                     act_departure_time, act_arrival_time, status,
                     created_at, updated_at)
SELECT
    'FL' || (100 + floor(random() * 60)::int),
    dep_time,
    dep_time + dur,
    dep_ap,
    ((dep_ap - 1 + 1 + floor(random() * 29)::int) % 30) + 1,
    chr(65 + floor(random()*6)::int) || (1 + floor(random()*30)::int),
    chr(65 + floor(random()*6)::int) || (1 + floor(random()*30)::int),
    1 + floor(random() * 20)::int,
    CASE WHEN dep_time < now() THEN dep_time + delay END,
    CASE WHEN dep_time < now() THEN dep_time + delay + dur + (random()*45 - 15) * INTERVAL '1 minute' END,
    CASE WHEN dep_time >= now()          THEN 'Scheduled'
         WHEN dep_time + delay + dur < now() THEN 'Arrived'
         ELSE 'Departed' END,
    dep_time - (30 + random()*90) * INTERVAL '1 day',
    dep_time - (random()*20) * INTERVAL '1 day'
FROM (
    SELECT date_trunc('minute',
             CASE WHEN r < 0.2
                  THEN now() - INTERVAL '3 days' + random() * INTERVAL '50 days'
                  ELSE now() - INTERVAL '3 years' + random() * INTERVAL '1095 days'
             END) AS dep_time,
           (60 + floor(random()*600)) * INTERVAL '1 minute'                                   AS dur,
           1 + floor(random() * 30)::int                                                     AS dep_ap,
           CASE WHEN r2 < 0.80 THEN (random()*65 - 5)  * INTERVAL '1 minute'
                WHEN r2 < 0.94 THEN (1 + random()*4)  * INTERVAL '1 hour'
                ELSE                (25 + random()*24) * INTERVAL '1 hour'
           END AS delay
    FROM (SELECT random() AS r, random() AS r2 FROM generate_series(1, 200)) x
) s;

UPDATE flights f2 SET flight_no = f1.flight_no
FROM (SELECT flight_no, row_number() OVER (ORDER BY flight_id) rn
      FROM flights WHERE airline_id = 1 AND extract(year FROM sch_arrival_time) <> 2024) f1,
     (SELECT flight_id, row_number() OVER (ORDER BY flight_id) rn
      FROM flights WHERE airline_id = 2 AND extract(year FROM sch_arrival_time) <> 2024) x
WHERE f2.flight_id = x.flight_id AND x.rn = f1.rn AND x.rn <= 3;

INSERT INTO booking (flight_id, passenger_id, booking_platform, created_at, updated_at, status, ticket_price)
SELECT f.flight_id,
       s.passenger_id,
       (ARRAY['Website','Mobile App','Leffler-Thompson','Aviasales','Kayak','Expedia','Bergstrom-Kuhn','Travel Agency'])[1 + floor(random()*8)::int],
       bt,
       bt + random() * INTERVAL '3 days',
       (ARRAY['Confirmed','Confirmed','Confirmed','Pending','Cancelled','Checked-in'])[1 + floor(random()*6)::int],
       round((5000 + random() * 40000)::numeric, 2)
FROM (SELECT i, (i*7 % 180) + 1 AS passenger_id, (i*13 % 190) + 1 AS fid
      FROM generate_series(1, 300) i) s
JOIN flights f ON f.flight_id = s.fid
CROSS JOIN LATERAL (SELECT least(f.sch_departure_time, now()) - (1 + random()*60) * INTERVAL '1 day' AS bt) t
ORDER BY s.i;

INSERT INTO booking_flight (booking_id, flight_id, created_at, updated_at)
SELECT booking_id, flight_id, created_at, updated_at FROM booking ORDER BY booking_id;

INSERT INTO boarding_pass (booking_id, seat, boarding_time, created_at, updated_at)
SELECT b.booking_id,
       (1 + floor(random()*35)::int) || chr(65 + floor(random()*6)::int),
       f.sch_departure_time - INTERVAL '40 minutes',
       f.sch_departure_time - INTERVAL '1 day',
       f.sch_departure_time - INTERVAL '1 day'
FROM booking b JOIN flights f ON f.flight_id = b.flight_id
WHERE b.status <> 'Cancelled'
ORDER BY b.booking_id;

INSERT INTO baggage (weight_in_kg, created_at, updated_at, booking_id)
SELECT round((1 + random() * 49)::numeric, 2),
       b.created_at + random() * INTERVAL '2 hours',
       b.created_at + INTERVAL '3 hours',
       b.booking_id
FROM (SELECT 1 + floor(random()*300)::int AS bid FROM generate_series(1, 200)) s
JOIN booking b ON b.booking_id = s.bid;

INSERT INTO baggage_check (check_result, created_at, updated_at, booking_id, passenger_id)
SELECT (ARRAY['Checked','Checked','Not checked','Rejected'])[1 + floor(random()*4)::int],
       ts,
       ts + random() * INTERVAL '5 days',
       b.booking_id,
       b.passenger_id
FROM (SELECT 1 + floor(random()*300)::int AS bid,
             TIMESTAMP '2023-01-01' + random() * (now() - TIMESTAMP '2023-01-01') AS ts
      FROM generate_series(1, 200)) s
JOIN booking b ON b.booking_id = s.bid;

UPDATE baggage_check
SET created_at = TIMESTAMP '2024-03-01' + (baggage_check_id % 28) * INTERVAL '1 day' + INTERVAL '10 hours',
    updated_at = TIMESTAMP '2024-03-01' + (baggage_check_id % 28) * INTERVAL '1 day' + INTERVAL '12 hours',
    check_result = 'Not checked'
WHERE baggage_check_id IN (3, 33, 63, 93, 123);

UPDATE baggage_check
SET created_at = date_trunc('month', created_at) + INTERVAL '20 days',
    updated_at = date_trunc('month', created_at) + INTERVAL '5 days'
WHERE baggage_check_id IN (10, 50, 90, 130, 170);

INSERT INTO security_check (check_result, created_at, updated_at, passenger_id)
SELECT (ARRAY['Passed','Passed','Passed','Passed','Failed','Additional check'])[1 + floor(random()*6)::int],
       ts, ts + INTERVAL '15 minutes', 1 + floor(random()*200)::int
FROM (SELECT TIMESTAMP '2023-01-01' + random() * (now() - TIMESTAMP '2023-01-01') AS ts
      FROM generate_series(1, 200)) s;

SELECT 'airline' AS table_name, count(*) FROM airline
UNION ALL SELECT 'airport',        count(*) FROM airport
UNION ALL SELECT 'passengers',     count(*) FROM passengers
UNION ALL SELECT 'flights',        count(*) FROM flights
UNION ALL SELECT 'booking',        count(*) FROM booking
UNION ALL SELECT 'booking_flight', count(*) FROM booking_flight
UNION ALL SELECT 'boarding_pass',  count(*) FROM boarding_pass
UNION ALL SELECT 'baggage',        count(*) FROM baggage
UNION ALL SELECT 'baggage_check',  count(*) FROM baggage_check
UNION ALL SELECT 'security_check', count(*) FROM security_check;
