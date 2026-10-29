Business Requirements Document (BRD)
Project: Cross-Band Structuring Scenario Optimization
Filing Alignment: FIU-IND (PMLA) / FinCEN (BSA)
________________________________________

1. Problem Statement
The current monitoring engine relies on static, single-transaction rules that flag individual transactions hitting the statutory reporting threshold (₹50,000 / $10,000).
Launderers routinely bypass this by executing rapid-fire transfers valued just beneath the line using multiple sender accounts directed into one destination account. Blanket-lowering the threshold across the entire bank causes an unsustainable spike in false-positive alerts. This scenario resolves the issue by pairing transaction value with velocity constraints.
________________________________________

2. Functional Rules (The 3-Pillar Setup)
An alert must be generated only when an account timeline meets all three of the following criteria:
1.	The Proximity Floor (Pillar 1): The initial transaction amount must fall within the structuring band.
o	Production Value: Between ₹40,000 and ₹49,999.
2.	Velocity Gap (Pillar 2): The next chronological transaction hitting the same account must arrive within a compressed time frame.
o	Production Value: Less than or equal to 12 Hours (<= 12).
3.	Pattern Recurrence (Pillar 3): The subsequent transaction value must also sit within a risk band to confirm intent.
o	Symmetric Standard: Between ₹40,000 and ₹49,999.
o	Asymmetric Extension: Between ₹15,000 and ₹49,999 (to catch de-escalating layered amounts).
________________________________________

3. Data Requirements & Logic Implementation
3.1 Required Ledger Fields
•	nameDest (String): Unique identifier for the destination account. Used as the timeline partition key.
•	step (Integer): Incremental hour marker tracking transaction execution time.
•	amount (Numeric): The value of the inbound transfer.
3.2 Technical Implementation Rules
•	Timeline Partitioning: The engine must group transactions by nameDest and sort them by step ascending to create independent chronological account histories.
•	Lookahead Querying: The system must use multi-row lookahead logic (LEAD) within a nested Common Table Expression (CTE) to check the next transaction attributes before filtering, ensuring full sequence visibility without breaking database performance.
________________________________________

4. Tuning Justification (Audit Trail)
The production thresholds are locked in based on empirical testing data from the validation ledger:
•	Baseline Run (₹45k–₹49.9k, 24 Hours): Generated 8 rows. Confirmed initial structuring activity.
•	Top-ATL Test (₹45k–₹48k, 24 Hours): Generated 0 rows. Proves capping the upper limit causes full signal decay because launderers operate right up against the ceiling.
•	Bottom-ATL Test (₹46k–₹49.9k, 24 Hours): Generated 7 rows. Dropping only 1 row indicates the ₹45k–₹46k band contains low-value noise.
•	BTL Blind-Spot Scan (₹40k–₹44.9k, 24 Hours): Generated 5 rows. Discovered a separate lower-tier smurfing ring operating beneath active netting.
•	Unified Production Optimization (₹40k–₹49.9k, 12 Hours): Generated 18 rows. Unifying the parameters and tightening the time rule captured 5 extra cross-band rows (e.g., accounts alternating high and low amounts, like Account C1568059495) that isolated queries completely missed.
________________________________________

5. Output Data Fields for Investigators
The final system alert must display the following fields for immediate compliance triage:
•	hour_gap: The exact hours between the transfers to confirm velocity.
•	total_structured_volume: The sum of the primary and secondary transaction amounts (amount + next_txn_amount) to track aggregated exposure for electronic filing narratives.
________________________________________

