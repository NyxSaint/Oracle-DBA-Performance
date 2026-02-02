CREATE OR REPLACE VIEW VW_OEM_ASH AS
WITH recent_ash AS (
  SELECT
    ash.session_id,
    ash.sql_id,
    ash.sample_time,
    ash.event,
    ash.wait_class,
    ash.action,
    ash.session_state
  FROM
    v$active_session_history ash
  JOIN
    v$session s ON ash.session_id = s.sid
  WHERE
    ash.sample_time >= SYSDATE - INTERVAL '10' MINUTE
    AND s.username IS NOT NULL
    AND s.type = 'USER'
    AND s.status = 'ACTIVE'
),
session_info AS (
  SELECT
    s.sid,
    s.serial#,
    NVL(s.username, 'UNKNOWN') AS username,
    NVL(s.status, 'UNKNOWN') AS status,
    TO_CHAR(s.logon_time, 'YYYY-MM-DD HH24:MI:SS') AS session_start_time,
    NVL(s.program, 'NO_PROGRAM') AS program,
    NVL(s.module, 'NO_MODULE') AS module,
    s.last_call_et
  FROM
    v$session s
  WHERE
    s.username IS NOT NULL
    AND s.type = 'USER'
    AND s.status = 'ACTIVE'
)
SELECT
  TO_CHAR(MAX(r.sample_time), 'YYYY-MM-DD HH24:MI:SS') AS last_sample_time,
  r.session_id || ',' || TO_CHAR(si.serial#) AS session_id,
  si.username,
  si.status AS session_status,
  si.session_start_time,
  NVL(MAX(r.session_state) KEEP (DENSE_RANK LAST ORDER BY r.sample_time), 'UNKNOWN') AS ash_state,
  NVL(MAX(r.wait_class) KEEP (DENSE_RANK LAST ORDER BY r.sample_time), 'CPU') AS last_wait_class,
  NVL(MAX(r.event) KEEP (DENSE_RANK LAST ORDER BY r.sample_time), 'NO_EVENT') AS last_event,
  NVL(MAX(r.action) KEEP (DENSE_RANK LAST ORDER BY r.sample_time), 'NO_ACTION') AS last_action,
  NVL(MAX(r.sql_id) KEEP (DENSE_RANK LAST ORDER BY r.sample_time), 'NO_SQL') AS last_sql_id,
  si.program,
  si.module,
  si.last_call_et AS seconds_since_last_call
FROM
  recent_ash r
JOIN
  session_info si ON r.session_id = si.sid
GROUP BY
  r.session_id,
  si.serial#,
  si.username,
  si.status,
  si.session_start_time,
  si.last_call_et,
  si.program,
  si.module
ORDER BY
  last_sample_time DESC;
