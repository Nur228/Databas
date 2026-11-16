# Lab 2 — Normalization (answers)

> Ответы на английском — их можно вставлять в отчёт как есть. Пометки «🇷🇺» — объяснение для тебя.

Source table:

```
Booking_receipt(booking_id, passenger_full_name, passenger_passport_number, flight_number,
                departure_airport_name, departure_city, arrival_airport_name, arrival_city,
                airline_name, seat_numbers, ticket_price)
```

Assumption: the passenger columns describe the person who made the booking; `ticket_price` is the total price of the booking; one `flight_number` identifies one flight.

---

## Task 1. Which normal form is violated and why

**The table is not even in 1NF**, so it is automatically not in 2NF or 3NF either.

| Normal form | Violated? | Responsible columns | Why |
|---|---|---|---|
| **1NF** | Yes | `seat_numbers` (and `passenger_full_name`) | 1NF requires atomic values. `seat_numbers` stores a list (`"12A, 12B"`), so one cell holds several values. You can't index, join or constrain individual seats. `passenger_full_name` is also composite (first name + last name in one field). |
| **2NF** | Yes | everything except `seat_numbers` | After 1NF the key becomes `(booking_id, seat_number)`. Columns like `flight_number`, `ticket_price`, passenger data depend only on `booking_id` — a **part** of the key (partial dependency). |
| **3NF** | Yes | `passenger_full_name`, `departure_city`, `arrival_city`, `airline_name`, airport names | Non-key attributes depend on other non-key attributes (transitive dependencies): `booking_id → flight_number → airline_name`, `flight_number → departure_airport_name → departure_city`, `booking_id → passport_number → passenger_full_name`. |

Practical problems (anomalies):
- **Update anomaly** — if an airline is renamed, we must update every receipt of every flight of that airline.
- **Insert anomaly** — we can't store a new airport or airline until somebody books a ticket.
- **Delete anomaly** — deleting the last booking of a flight deletes the only information about that flight's airports.

> 🇷🇺 Коротко: 1NF — «в одной ячейке одно значение»; 2NF — «каждая неключевая колонка зависит от ВСЕГО составного ключа»; 3NF — «неключевые колонки не зависят друг от друга, только от ключа».

---

## Task 2. Step-by-step normalization

Notation: **PK** = primary key (underlined in the report), *FK* = foreign key.

### Step 1 — 1NF
Split the seat list into separate rows and split the full name into atomic parts.

**Booking_receipt_1NF**(<u>booking_id</u>, <u>seat_number</u>, passenger_first_name, passenger_last_name, passenger_passport_number, flight_number, departure_airport_name, departure_city, arrival_airport_name, arrival_city, airline_name, ticket_price)

PK = (booking_id, seat_number)

| booking_id | seat_number | first | last | passport | flight | dep_airport | dep_city | arr_airport | arr_city | airline | price |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 12A | Aidar | Seitov | N1234567 | KC921 | Almaty Intl | Almaty | Astana Intl | Astana | Air Astana | 60000 |
| 1 | 12B | Aidar | Seitov | N1234567 | KC921 | Almaty Intl | Almaty | Astana Intl | Astana | Air Astana | 60000 |

### Step 2 — 2NF
Remove partial dependencies: everything except the seat depends only on `booking_id`.

- **Booking_2NF**(<u>booking_id</u>, passenger_first_name, passenger_last_name, passenger_passport_number, flight_number, departure_airport_name, departure_city, arrival_airport_name, arrival_city, airline_name, ticket_price)
- **Booking_seat**(<u>booking_id</u>*FK*, <u>seat_number</u>)

### Step 3 — 3NF
Remove transitive dependencies — every "fact about something else" goes to its own table.

- **Passenger**(<u>passport_number</u>, first_name, last_name)
- **Airline**(<u>airline_id</u>, airline_name)
- **Airport**(<u>airport_id</u>, airport_name, city)
- **Flight**(<u>flight_number</u>, *airline_id* → Airline, *departure_airport_id* → Airport, *arrival_airport_id* → Airport)
- **Booking**(<u>booking_id</u>, *passport_number* → Passenger, *flight_number* → Flight, ticket_price)
- **Booking_seat**(<u>booking_id</u> *→ Booking*, <u>seat_number</u>)

(`airline_id` and `airport_id` are surrogate keys — names can change, IDs never do.)

---

## Task 3. Functional dependencies used

| Step | Functional dependency | What it justified |
|---|---|---|
| 1NF | `seat_numbers` is multi-valued | splitting into one seat per row; key becomes (booking_id, seat_number) |
| 2NF | `booking_id → passenger_passport_number, flight_number, ticket_price` | these depend on part of the key → move to Booking |
| 2NF | `(booking_id, seat_number) → (nothing else)` | Booking_seat keeps only the key |
| 3NF | `passenger_passport_number → passenger_first_name, passenger_last_name` | Passenger table |
| 3NF | `flight_number → airline_name, departure_airport_name, arrival_airport_name` | Flight table |
| 3NF | `airline_name → (airline)` | Airline table |
| 3NF | `departure_airport_name → departure_city`, `arrival_airport_name → arrival_city` | Airport table |

Transitive chains removed: `booking_id → flight_number → airline_name`, `booking_id → flight_number → departure_airport_name → departure_city`, `booking_id → passport_number → passenger name`.

---

## Task 4. Is the `flights` table (from DDL) in 3NF?

`flights(flight_id, sch_departure_time, sch_arrival_time, departing_airport_id, arriving_airport_id, departing_gate, arriving_gate, airline_id, act_departure_time, act_arrival_time, created_at, updated_at)`

- **Primary key:** `flight_id` (single column → no partial dependencies possible → **2NF holds**).
- **Functional dependencies:** `flight_id → every other column`.
- **Transitive dependencies?** `departing_airport_id`, `arriving_airport_id` and `airline_id` are foreign keys. Facts about the airport (name, city, country) and the airline (name, country) are **not stored in `flights`** — they live in `airport` and `airline`. So there is no chain like `flight_id → airline_id → airline_name` *inside* this table. No non-key attribute determines another non-key attribute.
- **Conclusion: `flights` is in 3NF.** It would break 3NF only if we added, for example, `airline_name` or `departure_city` directly into `flights`.

> 🇷🇺 Главная мысль: FK-колонка сама по себе не нарушает 3NF. Нарушение — когда рядом с FK лежат данные, которые от него зависят (например airline_id + airline_name в одной таблице).

---

## Task 5
See [`normalization.sql`](normalization.sql) — creates the 3NF tables in a separate schema `receipt`, fills a denormalized table and splits it into the normalized ones with `INSERT … SELECT`.
