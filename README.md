# EV Charging Station Management System

An individual Web Application Project developed for the **Web Technology** course.

* **Project Title:** EV Charging Station Management System
* **Academic Review Stage:** LWP Review 01 (Stage 1 — Static Frontend with Meaningful Client-Side Scripting) & Stage 2 Ready
* **Primary Focus:** Electric Vehicle Charging Infrastructure Operations & Management

---

## 1. Project Overview

The **EV Charging Station Management System** is a responsive, web-based infrastructure operating platform built for companies that deploy and run electric vehicle charging networks. Rather than serving as a basic ride-booking or EV catalog website, the platform directly addresses real-world charging operations:

> **Core Objective:** *"Which charger is available, when can the customer use it, how much energy will be consumed, how long will charging take, and what will the estimated cost be?"*
> 
> **Operator Objective:** *"How efficiently are our charging stations and individual charging bays being utilized?"*

---

## 2. Technology Stack (Stage 1)

* **Markup:** HTML5 semantic structure
* **Styling:** CSS3, Modern Electric Mobility Palette (Midnight Slate, Electric Emerald `#00d084`, High-Voltage Cyan `#06b6d4`)
* **Framework:** Bootstrap 5.3.3 (Responsive Grid, Modals, Forms, Badges, Offcanvas)
* **Client-Side Scripting:** Vanilla JavaScript (ES6+) with `localStorage` state simulation
* **Data Visualizations:** Chart.js 4 (Energy Throughput Curves, Charger Health Breakdown, 24-hr Demand)
* **Iconography:** Bootstrap Icons 1.11.3

---

## 3. Project Directory Structure

```text
EV/
│
├── index.html                      # Modern EV-themed landing page & live teaser
│
├── pages/
│   ├── dashboard.html              # Central KPI dashboard & analytics
│   ├── stations.html               # Charging hub directory & filtering
│   ├── station-details.html        # Detailed station bay visual board
│   ├── chargers.html               # Charger hardware inventory & status control
│   ├── find-charger.html           # Geospatial & compatibility search
│   ├── reservations.html           # Conflict-free slot reservation system
│   ├── vehicles.html               # Customer EV fleet & battery management
│   ├── calculator.html             # Smart Charging Calculator (Feature 34)
│   ├── charging-session.html       # Live charging simulation with dynamic timers
│   ├── billing.html                # Itemized GST tax invoices & payment simulation
│   ├── maintenance.html            # Fault dispatch & auto-lockout tickets
│   ├── reports.html                # 5 Academic reports & CSV export
│   └── login.html                  # Role-based 1-click authentication demo
│
├── css/
│   ├── style.css                   # Core EV branding, battery graphics & components
│   ├── dashboard.css               # Sidebar, KPI cards, visual charger boards
│   └── responsive.css              # Breakpoints for desktop, tablet & mobile
│
├── js/
│   ├── app.js                      # Central state manager, seed data & helpers
│   ├── dashboard.js                # KPI calculations, Chart.js & recent tables
│   ├── stations.js                 # Station filtering & new station creation
│   ├── chargers.js                 # Utilization score calculation & status toggles
│   ├── reservations.js             # Double-booking conflict detection engine
│   ├── vehicles.js                 # Vehicle presets & battery level visualizer
│   ├── calculator.js               # Mathematical formulas & charging estimators
│   ├── charging.js                 # Live timer session simulator & kWh counter
│   └── maintenance.js              # Fault tickets, priority & charger auto-lock
│
├── database/                       # Stage 2 MySQL schema preparation
│   └── ev_charging_db.sql
│
├── LWP_REVIEW_01_PRESENTATION.md   # Complete 12-slide presentation notes
├── VIVA_QUESTIONS_GUIDE.md         # Viva exam questions & concise answers
└── README.md
```

---

## 4. Key Features & Academic Requirements Satisfied

### A. Role-Based Access Simulation (Section 5)
Four distinct user roles are simulated via a persistent switcher:
1. **Admin (`admin@evcharge.com`):** Global network management, station/charger inventory, financial reports, user access.
2. **Station Manager (`manager@evcharge.com`):** Local hub oversight, charger status distribution, station utilization & revenue.
3. **Technician (`tech@evcharge.com`):** Fault dispatch work orders, hardware status resolution, auto-locking faulty bays.
4. **Customer (`customer@evcharge.com`):** Station search, EV registration, conflict-free booking, session simulator, digital billing.

### B. Smart Charging Calculator (Section 16, 17, 18, 34)
* **Inputs:** Vehicle Battery Capacity (kWh), Current State of Charge (%), Target SoC (%), Charger Power (kW), Station Tariff (₹/kWh).
* **Formulas:**
  $$\text{Energy Required (kWh)} = \text{Battery Capacity} \times \frac{\text{Target \%} - \text{Current \%}}{100}$$
  $$\text{Ideal Charging Time} = \frac{\text{Energy Required}}{\text{Charger Power}}$$
  $$\text{Estimated Cost (₹)} = \text{Energy Required} \times \text{Price per kWh}$$
* **Interactive Feature:** Visual dynamic battery frame displaying level progression and color shifts.

### C. Visual Charger Availability Board (Section 35)
Dynamic visual grid displaying every charger bay in the station:
* **Green:** Available (ready for connection)
* **Cyan:** Charging (with real-time progress bar % & power draw)
* **Amber:** Reserved (locked for upcoming booking window)
* **Red:** Maintenance (hardware ticket active; locked from booking)
* **Grey:** Offline (telemetry disconnected)

### D. Double-Booking Conflict Prevention (Section 42 & 43)
Client-side reservation validation algorithm:
$$\text{Same Charger} + \text{Same Date} + \text{Overlapping Time Window} = \textbf{Reservation Conflict}$$
Prevents scheduling when a collision occurs and locks out any charger currently flagged as **Maintenance** or **Offline**.

### E. Live Charging Session Simulation (Section 20)
* Dynamic JavaScript timer simulating 1s = ~1 minute of rapid DC charging.
* Visual battery state increments, energy delivered (kWh) accumulates, power fluctuation simulates realistic BMS thermal throttling.
* "Complete Session & Bill" automatically terminates session, creates an itemized digital invoice, logs session into history, and frees the charger back to **Available**.

### F. Charger Utilization Score (Section 22)
Formula implemented across all chargers and hubs:
$$\text{Utilization (\%)} = \frac{\text{Charging Hours}}{\text{Available Operating Hours}} \times 100$$
Categorized into **High** ($\ge 75\%$), **Normal** ($40-74\%$), and **Low** ($< 40\%$).

### G. Academic Reports Module (Section 32 & 55)
1. **Charging Sessions Report**
2. **Energy Consumption Report**
3. **Station Revenue Report**
4. **Charger Utilization Report**
5. **Maintenance Tickets Report**

---

## 5. How to Run the Project

1. Clone or open the project folder `EV` in your favorite code editor (e.g. VS Code).
2. Simply double click `index.html` to open in Google Chrome or Microsoft Edge.
3. Or serve using any local HTTP server:
   ```bash
   # Using Python 3:
   python -m http.server 8080
   # Open browser at: http://localhost:8080
   ```
4. Explore all modules:
   * Click **Portal Login** or use the top-right **Role Switcher** to test Admin, Manager, Technician, or Customer views.
   * Try the **Smart Charging Calculator** on the home page or dedicated calculator page.
   * Go to **Slot Reservations** and attempt to book a slot; observe conflict detection and maintenance locks.
   * Go to **Charging Sessions** and run the live charging simulation.

---

## 6. Stage 2 (Dynamic Website with MySQL) Readiness

The data structure in `js/app.js` is 1:1 normalized with the Stage 2 relational database schema provided in `database/ev_charging_db.sql`. When transitioning to Stage 2 (LWP Review 02), the frontend remains identical while AJAX/Fetch calls replace `localStorage` with Servlets/JSP or PHP database endpoints.
