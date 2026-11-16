"""Собирает Lab1_ERD.pdf из erd.svg + текстового описания.
Запуск: python3 build_pdf.py   (нужен playwright с chromium)"""
from pathlib import Path
from playwright.sync_api import sync_playwright

HERE = Path(__file__).parent
svg = (HERE / "erd.svg").read_text()

entities = [
    ("Airline", "An airline company that operates flights.",
     "airline_id INT PK; airline_code VARCHAR(30) unique IATA-like code; airline_name VARCHAR(50); airline_country VARCHAR(50); created_at, updated_at TIMESTAMP"),
    ("Airport", "An airport where flights depart from or arrive to.",
     "airport_id INT PK; airport_name, country, state, city VARCHAR(50); created_at, updated_at TIMESTAMP"),
    ("Flights", "A scheduled flight with planned and actual times.",
     "flight_id INT PK; airline_id INT FK→Airline; departing_airport_id INT FK→Airport; arriving_airport_id INT FK→Airport; departing_gate, arriving_gate VARCHAR(50); sch_departure_time, sch_arrival_time, act_departure_time, act_arrival_time, created_at, updated_at TIMESTAMP"),
    ("Passengers", "A person who travels; stores personal and passport data.",
     "passenger_id INT PK; first_name, last_name, gender VARCHAR(50); date_of_birth DATE; country_of_citizenship, country_of_residence VARCHAR(50); passport_number VARCHAR(20) unique; created_at, updated_at TIMESTAMP"),
    ("Booking", "A ticket reservation made by a passenger for a flight.",
     "booking_id INT PK; flight_id INT FK→Flights; passenger_id INT FK→Passengers; status, booking_platform VARCHAR(50); ticket_price DECIMAL(7,2); created_at, updated_at TIMESTAMP"),
    ("Booking_flight", "Separate table that stores changes of the flight in a booking (history of re-bookings / legs).",
     "booking_flight_id INT PK; booking_id INT FK→Booking; flight_id INT FK→Flights; created_at, updated_at TIMESTAMP"),
    ("Boarding_pass", "Boarding pass issued for a booking.",
     "boarding_pass_id INT PK; booking_id INT FK→Booking; seat VARCHAR(50); boarding_time, created_at, updated_at TIMESTAMP"),
    ("Baggage", "A piece of luggage registered during booking.",
     "baggage_id INT PK; booking_id INT FK→Booking; weight_in_kg DECIMAL(4,2); created_at, updated_at TIMESTAMP"),
    ("Baggage_check", "Result of checking the baggage of a booking at the airport.",
     "baggage_check_id INT PK; booking_id INT FK→Booking; passenger_id INT FK→Passengers; check_result VARCHAR(50); created_at, updated_at TIMESTAMP"),
    ("Security_check", "Result of a passenger's airport security screening.",
     "security_check_id INT PK; passenger_id INT FK→Passengers; check_result VARCHAR(20); created_at, updated_at TIMESTAMP"),
]

relationships = [
    ("Airline — Flights", "1 : N", "One airline operates many flights; each flight belongs to exactly one airline (mandatory)."),
    ("Airport — Flights (departure)", "1 : N", "One airport is the departure point of many flights; each flight has exactly one departure airport."),
    ("Airport — Flights (arrival)", "1 : N", "One airport is the destination of many flights; each flight has exactly one arrival airport."),
    ("Flights — Booking", "1 : N", "A flight can have zero or many bookings; a booking is for exactly one flight."),
    ("Passengers — Booking", "1 : N", "A passenger can make zero or many bookings; a booking belongs to exactly one passenger."),
    ("Passengers — Flights", "M : N", "Many-to-many relationship resolved through the Booking table (linking table)."),
    ("Booking — Booking_flight", "1 : N", "A booking can have zero or many flight-change records."),
    ("Flights — Booking_flight", "1 : N", "A flight can appear in many flight-change records."),
    ("Booking — Boarding_pass", "1 : 0..1", "One-to-one: a booking gets at most one boarding pass; a pass belongs to exactly one booking."),
    ("Booking — Baggage", "1 : N", "A booking may register zero or many bags (baggage is optional)."),
    ("Booking — Baggage_check", "1 : N", "Every registered booking's baggage can be checked zero or many times."),
    ("Passengers — Baggage_check", "1 : N", "A passenger can have zero or many baggage check records."),
    ("Passengers — Security_check", "1 : N", "A passenger passes security zero or many times."),
]

ent_rows = "".join(f"<tr><td><b>{n}</b></td><td>{d}</td><td class='attr'>{a}</td></tr>" for n, d, a in entities)
rel_rows = "".join(f"<tr><td><b>{n}</b></td><td class='c'>{c}</td><td>{d}</td></tr>" for n, c, d in relationships)

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
@page {{ size: A4; margin: 16mm 14mm; }}
body {{ font-family: 'Helvetica Neue', Arial, sans-serif; color:#1a1a1a; font-size: 10.5pt; line-height:1.45; }}
h1 {{ font-size: 20pt; margin: 0 0 2mm; }}
h2 {{ font-size: 13pt; margin: 7mm 0 2mm; border-bottom: 2px solid #1f4e79; padding-bottom: 1mm; color:#1f4e79; }}
.sub {{ color:#555; margin-bottom: 4mm; }}
table {{ border-collapse: collapse; width:100%; font-size: 9pt; }}
th, td {{ border:1px solid #c8c8c8; padding: 4px 6px; vertical-align: top; text-align:left; }}
th {{ background:#eef3f8; }}
td.attr {{ font-family: Menlo, Consolas, monospace; font-size: 8pt; }}
td.c {{ text-align:center; white-space:nowrap; font-weight:bold; }}
.diagram {{ page-break-before: always; page-break-after: always; text-align:center; }}
.diagram svg {{ width: 100% !important; height: auto !important; max-height: 255mm; }}
.legend td:first-child {{ font-family: Menlo, monospace; white-space:nowrap; }}
</style></head><body>
<h1>Laboratory work 1 — ER Diagram</h1>
<div class="sub">Course: Databases &nbsp;·&nbsp; Topic: International Airport database</div>

<h2>1. Task overview</h2>
<p>The Airport database manages airport operations: airports, airlines, flights, passengers, bookings,
boarding passes, baggage registration and checks, and security checks. Below are the identified entities,
their attributes with data types and keys, the relationships with cardinality and participation,
the legend of the notation, and the ER diagram itself.</p>

<h2>2. Entities and attributes</h2>
<table><tr><th style="width:15%">Entity</th><th style="width:30%">Meaning</th><th>Attributes (type, keys)</th></tr>{ent_rows}</table>
<p>Every table has a surrogate primary key (<code>*_id</code>, INT) and audit columns
<code>created_at</code> / <code>updated_at</code> (TIMESTAMP) that record when a row was created and last changed.
All attributes are required (NOT NULL); <code>airline_code</code> and <code>passport_number</code> must be unique.</p>

<h2>3. Relationships</h2>
<table><tr><th style="width:28%">Relationship</th><th style="width:10%">Cardinality</th><th>Description / participation</th></tr>{rel_rows}</table>

<h2>4. Legend (Crow's Foot notation)</h2>
<table class="legend">
<tr><th>Symbol</th><th>Meaning</th></tr>
<tr><td>── ||</td><td>exactly one (mandatory participation)</td></tr>
<tr><td>── o|</td><td>zero or one (optional, at most one)</td></tr>
<tr><td>── o{{</td><td>zero or many (optional participation, "many" side)</td></tr>
<tr><td>── |{{</td><td>one or many</td></tr>
<tr><td>PK</td><td>Primary key — uniquely identifies a row</td></tr>
<tr><td>FK</td><td>Foreign key — references the primary key of another entity</td></tr>
<tr><td>UK</td><td>Unique key — value cannot repeat</td></tr>
<tr><td>decimal(7_2)</td><td>DECIMAL(7,2): 7 digits in total, 2 after the point (the comma is not allowed in the drawing tool)</td></tr>
</table>

<div class="diagram"><h2>5. ER Diagram</h2>{svg}</div>
</body></html>"""

out_html = HERE / "Lab1_ERD.html"
out_html.write_text(html)
with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page()
    pg.goto(out_html.resolve().as_uri())
    pg.pdf(path=str(HERE / "Lab1_ERD.pdf"), format="A4", print_background=True,
           margin={"top": "16mm", "bottom": "16mm", "left": "14mm", "right": "14mm"})
    b.close()
out_html.unlink()
print("OK -> Lab1_ERD.pdf")
