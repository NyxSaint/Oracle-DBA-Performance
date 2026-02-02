CREATE OR REPLACE VIEW VW_OEM_ACT_SESS_HISTORY AS
WITH
  minutes AS (
    SELECT TRUNC(SYSDATE, 'MI') - (10/1440) + (LEVEL - 1)/1440 AS minute_start_time
    FROM dual
    CONNECT BY LEVEL <= 10
  ),
  top_wait_classes AS (
    SELECT wait_class
    FROM (
      SELECT NVL(wait_class, 'CPU') AS wait_class, COUNT(*) AS sample_count
      FROM v$active_session_history
      WHERE sample_time >= SYSDATE - (10/1440)
        AND NVL(wait_class, 'CPU') != 'Idle'
      GROUP BY NVL(wait_class, 'CPU')
      ORDER BY sample_count DESC
    )
    FETCH FIRST 6 ROWS ONLY
  ),
  minute_wait_class AS (
    SELECT
      TO_CHAR(m.minute_start_time, 'HH24:MI') AS minute_label,
      w.wait_class,
      m.minute_start_time
    FROM minutes m
    CROSS JOIN top_wait_classes w
  ),
  totals AS (
    SELECT
      NVL(wait_class, 'CPU') AS wait_class,
      ROUND(COUNT(*) / 600, 2) AS total_aas
    FROM v$active_session_history
    WHERE sample_time >= SYSDATE - (10/1440)
      AND NVL(wait_class, 'CPU') != 'Idle'
    GROUP BY NVL(wait_class, 'CPU')
  ),
  ash_data AS (
    SELECT
      TO_CHAR(TRUNC(sample_time, 'MI'), 'HH24:MI') AS minute_label,
      NVL(wait_class, 'CPU') AS wait_class,
      COUNT(*) AS sample_count
    FROM v$active_session_history
    WHERE sample_time >= SYSDATE - (10/1440)
      AND NVL(wait_class, 'CPU') != 'Idle'
    GROUP BY TRUNC(sample_time, 'MI'), NVL(wait_class, 'CPU')
  )
SELECT
  mwc.minute_label,
  mwc.wait_class,
  ROUND(NVL(ad.sample_count, 0) / 60, 2) AS average_active_sessions,
  t.total_aas
FROM minute_wait_class mwc
LEFT JOIN ash_data ad
  ON ad.minute_label = mwc.minute_label
  AND ad.wait_class = mwc.wait_class
LEFT JOIN totals t
  ON t.wait_class = mwc.wait_class
WHERE mwc.minute_start_time < TRUNC(SYSDATE, 'MI')
ORDER BY
  mwc.minute_label,
  t.total_aas ASC,
  mwc.wait_class;
