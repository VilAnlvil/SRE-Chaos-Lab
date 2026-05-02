# stress_test.py — versión corregida
import requests
import time
import random
import os

# ✅ URL configurable por variable de entorno, con fallback a localhost
BASE_URL = os.getenv("TARGET_URL", "http://localhost:8000")
# ✅ Timeout configurable, default 5 segundos
TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", "5"))

def send_traffic():
    print(f"🚀 Generando tráfico hacia {BASE_URL}... (CTRL+C para parar)")
    while True:
        try:
            # Petición normal con timeout
            requests.get(f"{BASE_URL}/", timeout=TIMEOUT)

            # 10% de probabilidad de llamar a /health
            if random.random() < 0.1:
                requests.get(f"{BASE_URL}/health", timeout=TIMEOUT)

            time.sleep(0.5)  # ~2 peticiones por segundo

        except requests.Timeout:
            print("⏱️ Timeout en la petición — reintentando...")
            time.sleep(1)
        except Exception as e:
            print(f"❌ Error: {e}")
            time.sleep(1)

if __name__ == "__main__":
    send_traffic()
