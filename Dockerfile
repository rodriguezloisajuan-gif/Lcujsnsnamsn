FROM python:3.11-slim

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-setuptools \
    python3-pip \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements e instalar (forzar pip/setuptools/wheel)
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . /app

# Copiar entrypoint y darle permisos
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Crear usuario no privilegiado (opcional) y cambiar ownership
RUN useradd -m botuser && chown -R botuser:botuser /app
USER botuser

# Usar entrypoint que instalará setuptools en --user si falta y arranca el bot
ENTRYPOINT ["/app/entrypoint.sh"]
