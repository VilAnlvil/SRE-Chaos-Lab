FROM python:3.11-slim

WORKDIR /app

# Dependencias mínimas
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos todo el código fuente
COPY . .

# Puerto estándar para APIs
EXPOSE 8000

# 🔐 Security: correr como usuario no privilegiado
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser
USER appuser

# SRE Hardened: Usar 'python -m' para garantizar la localización del binario
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "info"]
