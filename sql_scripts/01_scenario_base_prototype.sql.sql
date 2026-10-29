-- =================================================================================
-- PROJECT: Anti-Money Laundering (AML) Transaction Monitoring Optimization Engine
-- ASSET: 01_scenario_base_prototype.sql
-- GOVERNANCE ALIGNMENT: FIU-IND (PMLA, 2002) & FinCEN (BSA) Compliance Frameworks
-- PURPOSE: Base prototype architecture. This script documents the baseline data
-- discovery phase, validation testing between originators and beneficiaries, 
-- and the initial engineering of the 3-Pillar window function rule.
-- =================================================================================

-- =================================================================================
-- INITIAL LEDGER AUDIT & DISCOVERY
-- =================================================================================
-- OBJECTIVE: Visual inspection of raw database structure.
SELECT * FROM paysim_table LIMIT 10;


-- =================================================================================
-- ORIGINATOR TIMELINE ANALYSIS
-- =================================================================================
-- OBJECTIVE: Test if launderers are structuring from the sender's side (nameOrig).
-- METHOD: Calculate baseline count of sequential payments originating from the same sender.
WITH partitioned_data AS (
    SELECT nameOrig, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameOrig ORDER BY step) AS next_amount,
        LEAD(step, 1) OVER (PARTITION BY nameOrig ORDER BY step) AS next_step 
    FROM paysim_table
)
SELECT COUNT(*) AS total_next FROM partitioned_data
WHERE next_step IS NOT NULL;

-- Observation: 0 patterns found on the originator's side; hence we would check from
-- the receipient's side of transactions.

-- =================================================================================
-- BENEFICIARY TIMELINE ANALYSIS
-- =================================================================================
-- OBJECTIVE: Shift focus to destination accounts (nameDest). Extracting a 50-row 
-- profile to visually verify chronological multi-row interaction patterns.
WITH partitioned_data_d AS (
    SELECT 
        nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
)
SELECT nameDest, amount, step, next_txn_amount, next_step FROM partitioned_data_d
WHERE next_step IS NOT NULL LIMIT 50;


-- =================================================================================
-- LOGIC EVALUATION AROUND REFERENCED THRESHOLD - CREATING AN ACTIVE NET
-- =================================================================================
-- OBJECTIVE: Check how many transactions naturally fall between ₹45,000 and ₹49,999 
-- consecutively.
WITH partitioned_data_baseline_count AS (
    SELECT 
        nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount
    FROM paysim_table
)
SELECT COUNT(*) AS total_struct FROM partitioned_data_baseline_count
WHERE amount BETWEEN 45000 AND 49999
AND next_txn_amount BETWEEN 45000 AND 49999;


-- =================================================================================
-- INTRODUCING VELOCITY FACTOR FOR THE TRANSACTIONS
-- =================================================================================
-- OBJECTIVE: Introducing the temporal constraint. Isolate destination accounts where
-- high-speed sequential occur within a rolling 24-hour window.
WITH partitioned_data_s AS (
    SELECT 
        nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
)
SELECT 
    nameDest, amount, step, next_step,
    (next_step - step) AS hour_gap 
FROM partitioned_data_s 
WHERE next_step IS NOT NULL
AND (next_step - step) <= 24;


-- =================================================================================
-- CHRONOLOGICAL BASELINE SCENARIO PROTOTYPE
-- =================================================================================
-- OBJECTIVE: Run the complete, finalized baseline rule combining the 3 pillars :
-- Pillar 1 (Value Band),
-- Pillar 2 (24-Hour Velocity), 
-- Pillar 3 (Recurrence Profile) 
-- to expose the system's first major structuring alert.

WITH partitioned_data_baseline_final AS (
    SELECT nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
)
SELECT nameDest, amount AS initial_amount, step AS initial_step,
    next_txn_amount, next_step,
    (next_step - step) AS hour_gap,
    (amount + next_txn_amount) AS total_structured_volume
FROM partitioned_data_baseline_final 
WHERE amount BETWEEN 45000 AND 49999
AND next_txn_amount BETWEEN 45000 AND 49999
AND (next_step - step) <= 24
ORDER BY nameDest, initial_step;