CREATE OR REPLACE VIEW VW_OEM_BLK_SESSIONS AS
WITH blocked_sessions AS (
  SELECT
    ash.sample_time,
    ash.session_id AS blocked_session_id,
    ash.blocking_session AS blocking_session_id,
    ash.sql_id AS blocked_sql_id,
    ash.event AS blocked_event,
    ash.wait_class AS blocked_wait_class,
    ash.machine AS blocked_machine,
    ash.program AS blocked_program,
    u.username AS blocked_user
  FROM v$active_session_history ash
  LEFT JOIN dba_users u ON ash.user_id = u.user_id
  WHERE ash.sample_time >= SYSDATE - (10/1440)
    AND ash.blocking_session IS NOT NULL
    AND ash.blocking_session != 0
    AND ash.wait_class IN ('Application', 'Concurrency')
)
SELECT
  TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI') AS minute_label,
  blocked_session_id,
  blocking_session_id,
  blocked_user,
  blocked_machine,
  blocked_program,
  blocked_sql_id,
  blocked_event,
  blocked_wait_class
FROM blocked_sessions
ORDER BY sample_time DESC;
