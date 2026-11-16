-- Raw tables, loaded exactly as they come from SAP (all text, no cleaning).
-- Dialect: PostgreSQL (RIGHT/LEFT also work in SQL Server and MySQL).

CREATE TABLE mb51_raw (
    material      TEXT,   -- 18 characters, zero-padded, sometimes with spaces
    plant         TEXT,
    storage_loc   TEXT,   -- text on purpose: '0001' keeps its leading zeros
    movement_type INTEGER,
    material_doc  TEXT,
    posting_date  TEXT,   -- '03.11.2026'
    quantity      TEXT,   -- negatives exported with a trailing minus: '50-'
    base_unit     TEXT
);

CREATE TABLE material_master (
    material       TEXT,
    description    TEXT,
    unit_price_eur NUMERIC
);
