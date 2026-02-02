CREATE OR REPLACE VIEW VW_OEM_RECENT_SQL AS
WITH recent_sql AS (
  SELECT
    m.sql_id,
    m.sql_exec_start,
    m.status,
    m.elapsed_time,
    m.cpu_time,
    m.buffer_gets,
    m.disk_reads,
    m.sql_plan_hash_value,
    m.sql_text
  FROM v$sql_monitor m
  WHERE m.sql_exec_start >= SYSDATE - (10 / 1440)
),
sql_users AS (
  SELECT
    s.sql_id,
    u.username
  FROM v$sql s
  JOIN dba_users u ON s.parsing_user_id = u.user_id
  GROUP BY s.sql_id, u.username
)
SELECT
  r.status,
  ROUND(r.elapsed_time / 1e6, 2) AS duration_seconds,
  r.sql_id,
  r.sql_plan_hash_value,
  COALESCE(u.username, 'UNKNOWN') AS username,
  ROUND(r.cpu_time / 1e6, 2) AS database_time_seconds,
  r.disk_reads AS io_requests,
  TO_CHAR(r.sql_exec_start, 'HH24:MI:SS') AS start_time,
  CASE
    WHEN r.status LIKE '%DONE%' THEN
      TO_CHAR(
        r.sql_exec_start + NUMTODSINTERVAL(r.elapsed_time / 1e6, 'SECOND'),
        'HH24:MI:SS'
      )
    ELSE
      ' '
  END AS end_time,
  SUBSTR(r.sql_text, 1, 200) AS sql_text
FROM recent_sql r
LEFT JOIN sql_users u ON r.sql_id = u.sql_id
ORDER BY
  CASE WHEN r.status LIKE '%EXECUTING%' THEN 0 ELSE 1 END,
  r.sql_exec_start DESC;
