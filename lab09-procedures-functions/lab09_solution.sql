CREATE OR REPLACE PROCEDURE add_flight(
    p_flight_no      VARCHAR,
    p_airline_id     INT,
    p_dep_airport_id INT,
    p_arr_airport_id INT,
    p_sch_departure  TIMESTAMP,
    p_sch_arrival    TIMESTAMP,
    p_dep_gate       TEXT    DEFAULT 'A1',
    p_arr_gate       VARCHAR DEFAULT 'B1'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_sch_arrival <= p_sch_departure THEN
        RAISE EXCEPTION 'Arrival time must be later than departure time';
    END IF;

    INSERT INTO flights (flight_no, airline_id, departing_airport_id, arriving_airport_id,
                         sch_departure_time, sch_arrival_time, departing_gate, arriving_gate, status)
    VALUES (p_flight_no, p_airline_id, p_dep_airport_id, p_arr_airport_id,
            p_sch_departure, p_sch_arrival, p_dep_gate, p_arr_gate, 'Scheduled');

    RAISE NOTICE 'Flight % added', p_flight_no; 
END;
$$;

CALL add_flight('KC999', 1, 1, 2, '2026-12-20 10:00', '2026-12-20 11:40');

SELECT flight_id, flight_no, airline_id, sch_departure_time, status
FROM flights WHERE flight_no = 'KC999';

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_flight_status(p_flight_id INT, p_status VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flights
    SET status = p_status, updated_at = now()
    WHERE flight_id = p_flight_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Flight with id % not found', p_flight_id;
    END IF;

    RAISE NOTICE 'Flight % status changed to %', p_flight_id, p_status;
END;
$$;

CALL update_flight_status(50000, 'Delayed');

SELECT flight_id, flight_no, status, updated_at FROM flights WHERE flight_id = 50000;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_flights_from_airport(p_airport_id INT)
RETURNS TABLE (flight_id INT, flight_no VARCHAR, to_city VARCHAR,
               sch_departure_time TIMESTAMP, status VARCHAR)
LANGUAGE sql
AS $$
    SELECT f.flight_id, f.flight_no, arr.city, f.sch_departure_time, f.status
    FROM flights f
    JOIN airport arr ON arr.airport_id = f.arriving_airport_id
    WHERE f.departing_airport_id = p_airport_id
    ORDER BY f.sch_departure_time DESC;
$$;

SELECT * FROM get_flights_from_airport(1) LIMIT 20; 

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION avg_arrival_delay(p_airport_id INT)
RETURNS INTERVAL
LANGUAGE sql
AS $$
    SELECT AVG(act_arrival_time - sch_arrival_time)
    FROM flights
    WHERE arriving_airport_id = p_airport_id
      AND act_arrival_time IS NOT NULL;
$$;

SELECT avg_arrival_delay(2) AS avg_delay_astana;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_passengers_by_flight_no(p_flight_no VARCHAR)
RETURNS TABLE (passenger_id INT, full_name TEXT, passport_number VARCHAR,
               sch_departure_time TIMESTAMP, booking_status VARCHAR)
LANGUAGE sql
AS $$
    SELECT p.passenger_id, p.first_name || ' ' || p.last_name, p.passport_number,
           f.sch_departure_time, b.status
    FROM booking b
    JOIN flights f    ON f.flight_id    = b.flight_id
    JOIN passengers p ON p.passenger_id = b.passenger_id
    WHERE f.flight_no = p_flight_no
    ORDER BY f.sch_departure_time, p.last_name;
$$;

SELECT * FROM get_passengers_by_flight_no('FL102');

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE top_passenger(
    OUT p_passenger_id INT,
    OUT p_full_name    TEXT,
    OUT p_flights      BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT p.passenger_id, p.first_name || ' ' || p.last_name, COUNT(*)
    INTO p_passenger_id, p_full_name, p_flights
    FROM booking b
    JOIN passengers p ON p.passenger_id = b.passenger_id
    WHERE b.status <> 'Cancelled'           
    GROUP BY p.passenger_id, p.first_name, p.last_name
    ORDER BY COUNT(*) DESC, p.passenger_id
    LIMIT 1;
END;
$$;

CALL top_passenger(NULL, NULL, NULL);

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_delayed_flights_24h()
RETURNS TABLE (flight_id INT, flight_no VARCHAR, sch_departure_time TIMESTAMP,
               act_departure_time TIMESTAMP, delay INTERVAL)
LANGUAGE sql
AS $$
    SELECT flight_id, flight_no, sch_departure_time, act_departure_time,
           act_departure_time - sch_departure_time
    FROM flights
    WHERE act_departure_time - sch_departure_time > INTERVAL '24 hours'
    ORDER BY 5 DESC;                               -- 5 = пятая колонка (delay)
$$;

SELECT * FROM get_delayed_flights_24h();

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION count_flights_per_airline()
RETURNS TABLE (airline_name VARCHAR, flights_count BIGINT)
LANGUAGE sql
AS $$
    SELECT al.airline_name, COUNT(f.flight_id)
    FROM airline al
    LEFT JOIN flights f ON f.airline_id = al.airline_id
    GROUP BY al.airline_id, al.airline_name
    ORDER BY 2 DESC;
$$;

SELECT * FROM count_flights_per_airline();

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE avg_ticket_price(IN p_flight_id INT, OUT p_avg_price NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT ROUND(AVG(ticket_price), 2)
    INTO p_avg_price
    FROM booking
    WHERE flight_id = p_flight_id;

    IF p_avg_price IS NULL THEN
        RAISE NOTICE 'Flight % has no bookings', p_flight_id;
    END IF;
END;
$$;
CALL avg_ticket_price(50000, NULL);

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE most_expensive_flight(
    OUT p_flight_no         VARCHAR,
    OUT p_departure_airport VARCHAR,
    OUT p_arrival_airport   VARCHAR,
    OUT p_ticket_price      NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT f.flight_no, dep.airport_name, arr.airport_name, b.ticket_price
    INTO p_flight_no, p_departure_airport, p_arrival_airport, p_ticket_price
    FROM booking b
    JOIN flights f   ON f.flight_id    = b.flight_id
    JOIN airport dep ON dep.airport_id = f.departing_airport_id
    JOIN airport arr ON arr.airport_id = f.arriving_airport_id
    ORDER BY b.ticket_price DESC
    LIMIT 1;
END;
$$;

CALL most_expensive_flight(NULL, NULL, NULL, NULL);

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_passenger(
    p_first_name  VARCHAR,
    p_last_name   VARCHAR,
    p_birth_date  DATE,
    p_gender      VARCHAR,
    p_citizenship VARCHAR,
    p_residence   VARCHAR,
    p_passport    VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO passengers (first_name, last_name, date_of_birth, gender,
                            country_of_citizenship, country_of_residence, passport_number)
    VALUES (p_first_name, p_last_name, p_birth_date, p_gender,
            p_citizenship, p_residence, p_passport);

    RAISE NOTICE 'Passenger % % added', p_first_name, p_last_name;
END;
$$;

CALL add_passenger('Nursultan', 'Testov', '2000-05-15', 'Male', 'Kazakhstan', 'Kazakhstan', 'KZ0909090');


SELECT passenger_id, first_name, last_name, passport_number FROM passengers WHERE passport_number = 'KZ0909090';

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_passenger_residence(p_passenger_id INT, p_country VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE passengers
    SET country_of_residence = p_country, updated_at = now()
    WHERE passenger_id = p_passenger_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Passenger with id % not found', p_passenger_id;
    END IF;
END;
$$;

CALL update_passenger_residence(1, 'Turkey');

SELECT passenger_id, first_name, country_of_residence FROM passengers WHERE passenger_id = 1;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_booking(p_booking_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_bf  INT;   -- booking_flight
    v_bag INT;   -- baggage
    v_bc  INT;   -- baggage_check
    v_bp  INT;   -- boarding_pass
BEGIN
    IF NOT EXISTS (SELECT 1 FROM booking WHERE booking_id = p_booking_id) THEN
        RAISE EXCEPTION 'Booking % does not exist', p_booking_id;
    END IF;

    SELECT COUNT(*) INTO v_bf  FROM booking_flight WHERE booking_id = p_booking_id;
    SELECT COUNT(*) INTO v_bag FROM baggage        WHERE booking_id = p_booking_id;
    SELECT COUNT(*) INTO v_bc  FROM baggage_check  WHERE booking_id = p_booking_id;
    SELECT COUNT(*) INTO v_bp  FROM boarding_pass  WHERE booking_id = p_booking_id;

    RAISE NOTICE 'Related records: booking_flight=%, baggage=%, baggage_check=%, boarding_pass=%',
                 v_bf, v_bag, v_bc, v_bp;

    IF v_bf + v_bag + v_bc + v_bp > 0 THEN
        DELETE FROM booking_flight WHERE booking_id = p_booking_id;
        DELETE FROM baggage        WHERE booking_id = p_booking_id;
        DELETE FROM baggage_check  WHERE booking_id = p_booking_id;
        DELETE FROM boarding_pass  WHERE booking_id = p_booking_id;
        RAISE NOTICE 'Related records deleted';
    END IF;

    DELETE FROM booking WHERE booking_id = p_booking_id;
    RAISE NOTICE 'Booking % deleted', p_booking_id;
END;
$$;

CALL delete_booking(1000);


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION count_passengers_by_country(p_country VARCHAR)
RETURNS BIGINT
LANGUAGE sql
AS $$
    SELECT COUNT(*) FROM passengers WHERE country_of_citizenship = p_country;
$$;

SELECT count_passengers_by_country('Kazakhstan') AS kazakhstan,
       count_passengers_by_country('France')     AS france;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION airline_revenue(p_airline_id INT)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(b.ticket_price), 0)
    FROM booking b
    JOIN booking_flight bf ON bf.booking_id = b.booking_id
    JOIN flights f         ON f.flight_id   = bf.flight_id
    WHERE f.airline_id = p_airline_id
      AND b.status <> 'Cancelled';
$$;

SELECT airline_name, airline_revenue(airline_id) AS revenue
FROM airline
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_passenger_bookings(p_passenger_id INT)
RETURNS TABLE (booking_id INT, booking_date TIMESTAMP, booking_status VARCHAR,
               booking_platform VARCHAR, ticket_price NUMERIC)
LANGUAGE sql
AS $$
    SELECT b.booking_id, b.created_at, b.status, b.booking_platform, b.ticket_price
    FROM booking b
    WHERE b.passenger_id = p_passenger_id
    ORDER BY b.created_at;
$$;

SELECT * FROM get_passenger_bookings(51213);

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION passengers_with_more_flights(p_min_flights INT)
RETURNS TABLE (passenger_id INT, full_name TEXT, flights_count BIGINT)
LANGUAGE sql
AS $$
    SELECT p.passenger_id, p.first_name || ' ' || p.last_name, COUNT(*)
    FROM passengers p
    JOIN booking b ON b.passenger_id = p.passenger_id
    GROUP BY p.passenger_id, p.first_name, p.last_name
    HAVING COUNT(*) > p_min_flights
    ORDER BY 3 DESC, 1;
$$;

SELECT * FROM passengers_with_more_flights(2);

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION count_arrivals(p_airport_id INT, p_from DATE, p_to DATE)
RETURNS BIGINT
LANGUAGE sql
AS $$
    SELECT COUNT(*)
    FROM flights
    WHERE arriving_airport_id = p_airport_id
      AND sch_arrival_time >= p_from
      AND sch_arrival_time <  p_to + 1;
$$;

SELECT count_arrivals(2, '2025-01-01', '2025-12-31') AS arrivals_astana_2025;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_old_bookings_status(p_before DATE, p_new_status VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE booking
    SET status = p_new_status, updated_at = now()
    WHERE created_at < p_before;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE '% bookings updated to status %', v_count, p_new_status;
END;
$$;

CALL update_old_bookings_status('2024-01-01', 'Archived');

SELECT booking_id, created_at, status FROM booking WHERE created_at < '2024-01-01';

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION passenger_summary(
    p_passenger_id INT,
    OUT full_name      TEXT,
    OUT total_bookings BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT first_name || ' ' || last_name
    INTO full_name
    FROM passengers
    WHERE passenger_id = p_passenger_id;

    IF NOT FOUND THEN
        full_name := 'Passenger not found';        
        total_bookings := 0;
        RAISE NOTICE 'Passenger with id % does not exist', p_passenger_id;
        RETURN;
    END IF;

    SELECT COUNT(*) INTO total_bookings FROM booking WHERE passenger_id = p_passenger_id;
END;
$$;

SELECT * FROM passenger_summary(51213);   
SELECT * FROM passenger_summary(99999999); 


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_type, routine_name;
