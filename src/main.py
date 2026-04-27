from fastapi import FastAPI, HTTPException, Response
from prometheus_fastapi_instrumentator import Instrumentator
import random
import time
import asyncio
import logging

# 📝 Configuración de logs para SRE (Diagnóstico de Inicio)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("🚀 API SRE Chaos Lab iniciando...")

app = FastAPI(title="SRE-Chaos-Lab", description="API diseñada para fallar y ser observada")

# --- OBSERVABILIDAD: Métrica Prometheus ---
Instrumentator().instrument(app).expose(app)

# Estado global del Caos
chaos_config = {
    "latency_enabled": False,
    "errors_enabled": False,
    "health_ok": True
}

@app.get("/")
async def root():
    logger.info("GET / - Root endpoint called")
    return {"status": "ok", "message": "Bienvenido al Laboratorio SRE"}

@app.get("/health")
async def health_check():
    # 🩺 Lógica de SRE: Si el switch está en False, lanzamos 500
    if not chaos_config["health_ok"]:
        logger.error("Health check failed (Chaos Injected)")
        raise HTTPException(status_code=500, detail="Unhealthy (Chaos Injected)")
    return {"status": "healthy", "timestamp": time.time()}

# --- MOTOR DE CAOS (Middlewares) ---

@app.middleware("http")
async def chaos_middleware(request, call_next):
    # 1. Inyección de Latencia
    if chaos_config["latency_enabled"] and request.url.path != "/chaos/latency/toggle":
        delay = random.uniform(2, 5)
        logger.warning(f"⚠️ Inyectando latencia: {delay:.2f}s")
        await asyncio.sleep(delay)
    
    # 2. Inyección de Errores
    if chaos_config["errors_enabled"] and request.url.path not in ["/chaos/errors/toggle", "/health"]:
        if random.random() < 0.3: # 30% de probabilidad
            logger.error("🔥 Error inyectado por el switch de caos")
            return Response(content="Internal Server Error (Chaos)", status_code=500)
            
    response = await call_next(request)
    return response

# --- ENDPOINTS DE CONTROL DE CAOS ---

@app.post("/chaos/latency/toggle")
async def toggle_latency():
    chaos_config["latency_enabled"] = not chaos_config["latency_enabled"]
    state = "ACTIVA" if chaos_config["latency_enabled"] else "DESACTIVADA"
    logger.info(f"Latencia {state}")
    return {"message": f"Inyección de latencia {state}"}

@app.post("/chaos/errors/toggle")
async def toggle_errors():
    chaos_config["errors_enabled"] = not chaos_config["errors_enabled"]
    state = "ACTIVA" if chaos_config["errors_enabled"] else "DESACTIVADA"
    logger.info(f"Errores 500 {state}")
    return {"message": f"Inyección de errores {state}"}

@app.post("/chaos/health/toggle")
async def toggle_health():
    chaos_config["health_ok"] = not chaos_config["health_ok"]
    state = "HEALTHY" if chaos_config["health_ok"] else "UNHEALTHY"
    logger.info(f"Estado de salud cambiado a {state}")
    return {"message": f"App ahora está {state}"}
