CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    toilet_id INTEGER NOT NULL,
    is_free BOOLEAN NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION has_free_toilet() RETURNS BOOLEAN AS $$
DECLARE
    has_free BOOLEAN;
BEGIN
    WITH latest_events AS (
        SELECT DISTINCT ON (toilet_id) *
        FROM events
        ORDER BY toilet_id, recorded_at DESC
    )
    SELECT INTO has_free EXISTS (SELECT 1 FROM latest_events WHERE is_free);
    RETURN has_free;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW visits AS SELECT * FROM (
  SELECT toilet_id, is_free, recorded_at, lead(recorded_at)
  OVER (PARTITION BY toilet_id ORDER BY recorded_at) - recorded_at AS duration
  FROM events
  ORDER BY recorded_at
) e
WHERE NOT is_free;
