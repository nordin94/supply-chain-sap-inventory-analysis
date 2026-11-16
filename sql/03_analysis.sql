-- Step 4: business questions on the clean view.

-- Net stock change for the week (units)
SELECT SUM(quantity) AS net_change
FROM mb51_clean;                                     -- 1103

-- Real goods receipts: 101 minus reversals 102
SELECT SUM(quantity) AS real_receipts
FROM mb51_clean
WHERE movement_type IN (101, 102);                   -- 1550

-- Scrapped units (shown as a positive number)
SELECT -SUM(quantity) AS scrapped_units
FROM mb51_clean
WHERE movement_type = 551;                           -- 17

-- Scrap value in EUR (JOIN = the VLOOKUP of SQL)
SELECT -SUM(m.quantity * p.unit_price_eur) AS scrap_value_eur
FROM mb51_clean m
JOIN material_master p ON m.material = p.material
WHERE m.movement_type = 551;                         -- 116

-- Movement summary by type
SELECT movement_type, SUM(quantity) AS units
FROM mb51_clean
GROUP BY movement_type
ORDER BY movement_type;

-- Step 5: reconciliation. The two storage locations must add up to the plant total.
SELECT storage_loc, SUM(quantity) AS net_change
FROM mb51_clean
GROUP BY storage_loc;                                -- 0001: 1053 | 0002: 50
