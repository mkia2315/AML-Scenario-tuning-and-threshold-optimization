-- =================================================================================
-- PROJECT: Anti-Money Laundering (AML) Transaction Monitoring Optimization Engine
-- ASSET: Model Validation Framework (ATL/BTL Threshold Tuning Simulations)
-- GOVERNANCE ALIGNMENT: FIU-IND (PMLA, 2002) & FinCEN (BSA) Defensibility Mandates
-- AUTHOR: 10+ Years Financial Crime Compliance (FCC) Specialist
-- =================================================================================
-- PURPOSE: This script details the complete algorithmic model validation workflow. 
-- It traces the iterative path from the initial baseline setup, through Above-The-Line 
-- (ATL) tightening cycles, Below-The-Line (BTL) blind-spot expansion, and concludes 
-- with the final asymmetric production-grade deployment model.
-- =================================================================================

-- =================================================================================
-- INITIAL BASELINE PROTOTYPE SETUP (RUN 1)
-- =================================================================================
-- OBJECTIVE: Establish a benchmark rule capturing uniform consecutive inflows flirting 
-- with the static ₹50,000 regulatory reporting threshold.
-- TARGET PROFILE: High-velocity transfers between ₹45,000 and ₹49,999 within 24 hours.

WITH baseline_partition_data AS (
    SELECT nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 45000 AND 49999
)
SELECT 
    nameDest, amount AS initial_amount, step AS initial_step,
    next_txn_amount, next_step,
    (next_step - step) AS hour_gap,
    (amount + next_txn_amount) AS total_structured_volume
FROM baseline_partition_data 
WHERE
	next_txn_amount IS NOT NULL
    AND next_txn_amount BETWEEN 45000 AND 49999
    AND (next_step - step) <= 24
ORDER BY nameDest, initial_step;


-- =================================================================================
-- ABOVE-THE-LINE (ATL) SIMULATION CYCLES
-- =================================================================================
-- OBJECTIVE: Tighten rules to minimize alert volumes and test statistical limits.

-- Cycle 2A: Top-Tight Thresholding (Narrowing upper limits)
WITH atl_top_tight_data AS (
    SELECT 
        nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 45000 AND 48000
)
SELECT nameDest, (next_step - step) AS hour_gap FROM atl_top_tight_data 
WHERE next_txn_amount BETWEEN 45000 AND 48000
AND (next_step - step) <= 24;

-- Cycle 2B: Bottom-Tight Thresholding (Raising the floor to ₹46,000)
WITH atl_bottom_tight_data AS (
    SELECT nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 46000 AND 49999
)
SELECT nameDest, (next_step - step) AS hour_gap FROM atl_bottom_tight_data 
WHERE next_txn_amount BETWEEN 46000 AND 49999
    AND (next_step - step) <= 24;


-- =================================================================================
-- BELOW-THE-LINE (BTL) TESTING (RUN 4)
-- =================================================================================
-- OBJECTIVE: Proactively hunt for risk signatures operating completely outside 
-- active monitoring nets (testing between ₹40,000 and ₹44,999).

WITH btl_data AS (
    SELECT 
        nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 40000 AND 44999
)
SELECT nameDest, amount AS initial_amount, next_txn_amount,
	   (next_step - step) AS hour_gap FROM btl_data 
WHERE next_txn_amount BETWEEN 40000 AND 44999
	AND (next_step - step) <= 24;


-- =================================================================================
-- UNIFIED BANDING OF THE LIMITS
-- =================================================================================
-- OBJECTIVE: Merge parameters based on BTL discoveries to fully capture 
-- Cross-Band Layering patterns (₹40,000 to ₹49,999).

WITH unified_production_data AS (
    SELECT nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 40000 AND 49999
)
SELECT nameDest, amount AS initial_amount, step AS initial_step,
    next_txn_amount, next_step,
    (next_step - step) AS hour_gap,
    (amount + next_txn_amount) AS total_structured_volume
FROM unified_production_data 
WHERE next_txn_amount IS NOT NULL 
      AND next_txn_amount BETWEEN 40000 AND 49999
      AND (next_step - step) <= 24
ORDER BY nameDest, initial_step;


-- =================================================================================
-- ADVANCED ASYMMETRIC DE-ESCALATION CONFIGURATION
-- =================================================================================
-- OBJECTIVE: Catch highly sophisticated syndicates utilizing variable transaction
-- sizes (starting high to optimize threshold limits, then dropping residual volumes lower).

WITH partitioned_data_asym AS (
    SELECT nameDest, amount, step,
        LEAD(amount, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_txn_amount,
        LEAD(step, 1) OVER (PARTITION BY nameDest ORDER BY step) AS next_step 
    FROM paysim_table
    WHERE amount BETWEEN 40000 AND 49999
)
SELECT 
    nameDest, amount AS initial_amount, step AS initial_step,
    next_txn_amount, next_step,
    (next_step - step) AS hour_gap,
    (amount + next_txn_amount) AS total_structured_volume
FROM partitioned_data_asym 
WHERE next_txn_amount IS NOT NULL
    AND amount BETWEEN 40000 AND 49999
    AND next_txn_amount BETWEEN 15000 AND 49999   
    AND (next_step - step) <= 12                  
ORDER BY nameDest, initial_step;
