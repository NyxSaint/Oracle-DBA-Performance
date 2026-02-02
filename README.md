# Oracle DBA Performance Suite: SQL-Based Monitoring 📊

Este repositorio es una colección de herramientas avanzadas para el diagnóstico de rendimiento en bases de datos Oracle (OCI / On-Premise), diseñadas para emular las métricas críticas de **Oracle Enterprise Manager (OEM)**.

## 🛠️ Herramientas Incluidas / Included Tools

### 1. View: VW_OEM_ACT_SESS_HISTORY
- **Propósito:** Análisis de carga (AAS - Average Active Sessions).
- **Valor:** Visualiza los últimos 10 minutos de carga de la base de datos divididos por clase de espera.

### 2. View: VW_OEM_ASH
- **Propósito:** Tracking detallado de sesiones activas.
- **Valor:** Captura el estado exacto, SQL_ID y evento de espera actual de cada sesión de usuario.

### 3. View: VW_OEM_RECENT_SQL
- **Propósito:** Monitorización de ejecuciones SQL en tiempo real.
- **Valor:** Analiza el consumo de CPU, I/O y duración de los SQLs más pesados usando `v$sql_monitor`.

### 4. View: VW_OEM_BLK_SESSIONS
- **Propósito:** Detección y análisis de bloqueos (Blocking Sessions).
- **Valor:** Identifica sesiones bloqueadas y sus causantes, filtrando por eventos de contención y aplicación.

---

## 📝 Requisitos Técnicos / Technical Requirements
- Oracle Database 12c, 19c o 21c.
- Licenciamiento de **Diagnostic & Tuning Pack** (ya que utiliza vistas ASH y SQL Monitor).
- Privilegios de `SELECT` sobre vistas dinámicas de performance.
- Privilegios hacia los diccionarios de datos.

**Autor:** Luis Barba Sosa 
**Oracle ACE Apprentice**
