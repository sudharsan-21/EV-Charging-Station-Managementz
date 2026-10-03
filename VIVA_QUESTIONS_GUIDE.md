# VIVA QUESTIONS & ANSWERS GUIDE

## EV Charging Station Management System
**Academic Individual Project — Web Technology Course**

---

### Q1: What is an EV Charging Station Management System?
**Answer:**  
An EV Charging Station Management System is a specialized web-based application designed to manage the physical and digital operations of electric vehicle charging infrastructure. It handles charging station hubs, individual charging points (EVSEs), customer vehicle profiles, conflict-free slot reservations, live charging sessions, energy consumption metering, billing and payments, and technician maintenance workflows.

---

### Q2: Why did you choose this individual project?
**Answer:**  
With the rapid electrification of transportation, managing the charging infrastructure is the single most critical operational bottleneck. Rather than building a conventional e-commerce or booking website, this project tackles real-world engineering challenges: power delivery limits, connector compatibility, slot overlap prevention, battery charging physics, and charger utilization efficiency.

---

### Q3: What is a "Charging Session"?
**Answer:**  
A charging session represents the continuous time interval during which an electric vehicle is plugged into a charger bay, drawing electrical energy through its Battery Management System (BMS). It tracks the start timestamp, end timestamp, total kilowatt-hours (kWh) transferred, elapsed duration, peak power output, and resulting monetary cost.

---

### Q4: How is charging cost calculated in your system?
**Answer:**  
The base charging cost formula is:
$$\text{Base Cost (₹)} = \text{Energy Consumed (kWh)} \times \text{Tariff Rate (₹/kWh)}$$
The complete invoice calculation includes:
$$\text{Total Invoice Amount} = \text{Base Cost} + \text{Station Service Fee (₹20)} + \text{GST (9\%) Tax}$$
In Stage 1, this is calculated client-side via JavaScript; in Stage 2, it is computed server-side from database records.

---

### Q5: How do you estimate charging time? Why is it labeled an "ideal" estimate?
**Answer:**  
The ideal charging duration is calculated as:
$$\text{Ideal Charging Time (hours)} = \frac{\text{Energy Required (kWh)}}{\text{Charger Power (kW)}}$$
$$\text{Where: } \text{Energy Required} = \text{Battery Capacity} \times \frac{\text{Target \%} - \text{Current \%}}{100}$$
**Academic Clarification for Viva:**  
This is labeled an ideal calculation because in physical reality, lithium-ion battery charging is non-linear. The vehicle's Battery Management System follows a **CC/CV (Constant Current / Constant Voltage)** curve, where charging speed throttles significantly once the battery exceeds 80% State of Charge (SoC) to protect cell chemistry and manage thermal dissipation.

---

### Q6: What is "Charger Utilization Score" and how is it calculated?
**Answer:**  
Charger utilization measures how effectively a physical charging point is generating value during its available operating hours.
$$\text{Utilization (\%)} = \frac{\text{Charging Hours Used}}{\text{Available Operating Hours}} \times 100$$
* **High Utilization:** $\ge 75\%$ (Heavy demand, candidate for capacity expansion)
* **Normal Utilization:** $40\% - 74\%$ (Balanced throughput)
* **Low Utilization:** $< 40\%$ (Underutilized asset)

---

### Q7: How does your reservation conflict prevention algorithm work?
**Answer:**  
Before confirming any slot reservation, the system checks existing bookings for collisions:
$$\text{Same Charger ID} + \text{Same Date} + \left(\text{New Start Time} < \text{Existing End Time} \;\land\; \text{New End Time} > \text{Existing Start Time}\right)$$
If an overlap exists, the system flags a **Reservation Conflict** and blocks the submission. Furthermore, chargers with an operational status of **Maintenance** or **Offline** are automatically locked out from reservations.

---

### Q8: What connector types and power levels are supported?
**Answer:**  
The system recognizes that different EVs and charging stations have distinct electrical standards:
* **Connectors:**
  * `CCS2` (Combined Charging System 2 — European/Indian standard DC fast charging)
  * `Type 2` (Mennekes — Standard AC single/three-phase)
  * `CHAdeMO` (Japanese DC fast charging protocol)
  * `GB/T` (Chinese standard DC fast charging)
* **Power Ratings:**
  * AC: $7.4\text{ kW}$ (Slow single-phase), $22\text{ kW}$ (Fast three-phase)
  * DC: $30\text{ kW}$, $60\text{ kW}$ (DC Rapid), $120\text{ kW}$ (DC Ultra), $150\text{ kW}$ (DC Hyper)

---

### Q9: Why use JavaScript in Stage 1?
**Answer:**  
JavaScript provides meaningful client-side scripting required for LWP Review 01:
1. Dynamic state management with `localStorage` persistence across all pages.
2. Real-time mathematical computations (charging cost, energy required, duration).
3. Conflict validation algorithms and input sanity checks.
4. Interval timers that animate battery progression and live power fluctuations in the session simulation.
5. Dynamic rendering of tables, visual charger boards, modal dialogs, and toast alerts.

---

### Q10: Why MySQL in Stage 2?
**Answer:**  
MySQL provides a robust, ACID-compliant relational database management system. It guarantees data integrity across multi-table relationships (Users $\rightarrow$ Vehicles $\rightarrow$ Reservations $\rightarrow$ Sessions $\rightarrow$ Payments) using foreign keys, enforces transactional consistency to eliminate double booking race conditions, and supports prepared statements for SQL injection prevention.

---

### Q11: What is the architectural difference between Stage 1 and Stage 2?
**Answer:**  
* **Stage 1 (LWP Review 01):** Complete frontend UI (HTML5, CSS3, Bootstrap 5) with client-side JavaScript handling simulation, validation, and browser `localStorage` persistence.
* **Stage 2 (LWP Review 02):** Extends the exact same UI by replacing `localStorage` calls with AJAX/Fetch requests to server-side controllers (Java Servlets or PHP), which execute prepared SQL statements on the normalized `ev_charging_db` MySQL database.
