# 📔 SRE Operation Log - Chaos Lab

Este archivo es el registro histórico de operaciones, decisiones de arquitectura y tareas de mantenimiento ejecutadas en el proyecto.

---

## [2026-03-01] - Cierre de Sesión: Estabilización y Observabilidad Nativa
**Acción:** 
- Corrección de la inicialización de `prometheus-fastapi-instrumentator`.
- Implementación de `logConfiguration` (awslogs) en Terraform.
- Importación del Log Group `/ecs/sre-chaos-api` al estado de IaC.
- Redespliegue forzado y validación de logs en CloudWatch.

**Justificación & Compliance:** 
- **Problema:** El contenedor ECS moría con código 1 sin dejar rastro ("Black Box problem").
- **Flujo de Pensamiento:** 
    1. *Identificación:* El método `.bootstrap()` no existía en la versión actual de la librería.
    2. *Hipótesis:* A pesar del fix de código, el sistema seguía fallando. La falta de visibilidad impedía ver si era un error de red, de permisos o de Python.
    3. *Razonamiento:* En SRE, "no puedes arreglar lo que no puedes ver". Se priorizó la infraestructura de observabilidad antes que seguir adivinando el error de código.
    4. *Solución:* Al habilitar `awslogs` en la Task Definition, CloudWatch finalmente nos habló, confirmando que el servidor Uvicorn estaba listo.

**Buenas Prácticas Respetadas:**
- **Observabilidad Nativa:** Uso de CloudWatch Logs para diagnóstico de tiempo real.
- **IaC Determinista:** Todo cambio de infraestructura pasó por Terraform, incluyendo el `import` de recursos huérfanos.
- **MTTR (Mean Time To Recovery):** Reducción del tiempo de diagnóstico mediante inyección de logs proactivos.
- **Principio de Menor Privilegio:** Uso de roles estándar de ejecución de ECS.

**Mejoras para el Futuro:**
- **Determinismo de Imágenes:** Dejar de usar el tag `:latest` y pasar a usar el SHA de la imagen o el ID del Build para evitar el error de `ImageNotFound` durante el pull inicial.
- **Alerting:** Implementar métricas de CloudWatch sobre el conteo de `failedTasks` para detectar CrashLoops automáticamente.
- **Liveness Probes:** Refinar el `startPeriod` del health check de ECS para evitar reinicios prematuros en arranques pesados.

**Resultado:** ✅ API Saludable, Logs visibles y Sistema 100% bajo control de Terraform.

---

## [2026-04-27] - Optimización de Portafolio y Motor de Caos
**Acción:** 
- Implementación completa de middlewares de Caos (Latencia y Errores 500).
- Reestructuración del `README.MD` con estándar de portafolio SRE (Mermaid, Golden Signals).
- Alineación del código con el plan de "Self-Healing Infrastructure".

**Justificación & Compliance:** 
- **Efectividad:** El código ahora coincide con la documentación técnica, evitando falsas expectativas.
- **Atractivo:** Uso de diagramas de arquitectura para facilitar la comprensión del sistema en revisiones rápidas de reclutadores.
- **SRE Principles:** Enfoque en las 4 Golden Signals como métricas de éxito.

**Resultado:** ✅ Repositorio listo para ser compartido. Código funcional para demos en vivo.

---
*Checkpoint SRE: El laboratorio ahora no solo funciona, sino que cuenta una historia de ingeniería.*
