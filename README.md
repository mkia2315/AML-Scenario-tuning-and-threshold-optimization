Optimizing AML Transaction Monitoring: Catching Cross-Band Structuring


If an AML rule only checks for single transactions over ₹50,000 (the standard statutory threshold), it is completely blind to structured layering rings. Bad actors bypass this daily by splitting large sums into rapid-fire deposits right below the radar, like transferring ₹49,177 and ₹42,529 to the same beneficiary within the same hour.

Blanket-lowering an entire bank's monitoring thresholds to trap these micro-transfers causes an overwhelming spike in false-positive alerts that burns out compliance operations teams.
This data-driven tuning framework uses a production sample from a 6.3M+ record financial ledger. By deploying nested SQL window engines over static WHERE filters, it isolates coordinated smurfing networks without generating operational noise.

---
I) Repository Structure

```text
├── sql_scripts
│   ├── 01_scenario_base_prototype.sql       # Baseline exploration
│   └── 02_atl_btl_tuning_simulations.sql    # Step-by-step ATL/BTL threshold optimization
├── documentation
│   └── Business_Requirements_Document.md    # Functional specs and regulatory alignment (RBI/FinCEN)
```
---
II) Detection Logic: The 3-Pillar Rule

To accurately identify structured money flows, the transaction engine evaluates data against three dimensions:

1. The Proximity Band (Pillar 1):  Targets individual inbound amounts sitting right under the legal ceiling.
2. Temporal Velocity (Pillar 2):  Restricts the engine to high-speed, close-proximity transactions using a tight rolling time window.
3. Behavioral Recurrence (Pillar 3):  Validates that subsequent transactions maintain a sub-threshold profile to verify intent.

---
III) The Model Tuning Matrix (Empirical Ledger Results)

To make this scenario completely defensible to internal model risk validation teams and federal regulators, the logic was subjected to rigorous Above-the-Line (ATL) and Below-the-Line (BTL) testing iterations.

| Execution Cycle | Tested Parameter Band | Temporal Threshold | Alert Volume | Target Signal Integrity | Strategic Compliance Takeaway |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Initial Baseline** | 45,000 – 49,999 | <= 24 Hours | 8 | 100% | Baseline Target. Confirms presence of highly anomalous activity right below the threshold. |
| **Top-ATL Simulation** | 45,000 – 48,000 | <= 24 Hours | 0 | 0% | Capping the upper limit missed 100% of suspects. Proves launderers cluster close to the line. |
| **Bottom-ATL Simulation** | 46,000 – 49,999 | <= 24 Hours | 7 | 87.5% | Dropping 1 row indicates the 45k–46k zone contains mostly background noise. |
| **BTL Blind-Spot Test** | 40,000 – 44,999 | <= 24 Hours | 5 | 100% | Proves syndicates are deliberately moving money further down the value chain. |
| **Optimized Unified** | 40,000 – 49,999 | <= 12 Hours | 18 | 100% | Unlocked 5 hidden cross-band alerts that isolated queries dropped. |

---
IV) Core Operational Insights

1. The Cross-Band Layering Hidden Value : Running independent, bracketed rules (e.g., assessing 40k-45k separate from 45k-50k) fails completely. The mathematical sum of our isolated baseline (8 alerts) and BTL test (5 alerts) is  13 alerts. However, when unified into a single parameter net (₹40,000 to ₹49,999), the engine generated  18 alerts . The 5 extra rows represent sophisticated accounts where actors deliberately staggered amounts across boundaries (e.g., Account `C1568059495` alternating ₹49,177.38 and ₹42,529.28). Merging parameters provides the macro visibility needed to bridge the gap.

2. Velocity Calibration : True positive risks cluster heavily. Ledger evaluation showed that genuine positive structuring patterns consistently operate with a  0-to-2 hour velocity gap, validating that compressing the production framework from a 24-hour boundary down to a 12-hour rule maximizes signal density and remains highly defensible for an external regulatory audit.

3. Asymmetric De-escalation : Advanced launderers often use a "De-escalation Pattern"—making a high-value initial deposit right below the line, followed immediately by smaller asymmetric transfers (e.g., down to ₹15,000) to defeat uniform pattern-matchers. The tuning script builds out an asymmetric tracking extension to lock down this specific loophole.

---
V) Tools & Technology Stack

Language & Engine:  Advanced SQL Window Function Lookahead Architecture.

Core Analytics:  Nested Common Table Expressions (CTEs), multi-offset lookahead frames (LEAD/LAG), and relational partitioning.

Domain Focus:  Anti-Money Laundering (AML) Transaction Monitoring, Scenario Optimization, Alert Tuning, and Model Defensibility.
