FROM python:3.11-slim

# Instalar dependencias del sistema necesarias para compilar extensiones Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-setuptools \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements e instalar (actualizamos pip para favorecer wheels)
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . /app

# Crear usuario no privilegiado (opcional)
RUN useradd -m botuser && chown -R botuser:botuser /app
USER botuser

# Comando de arranque
CMD ["python", "bot.py"]
