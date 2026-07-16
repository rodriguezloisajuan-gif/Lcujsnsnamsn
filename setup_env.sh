#!/usr/bin/env bash
# setup_env.sh
# Script interactivo para crear un archivo .env localmente con tus credenciales
# No añade el .env al repositorio. Ejecuta desde la raíz del proyecto.

set -euo pipefail

echo "Este script crea un archivo .env en el directorio actual. Nunca subas ese .env a un repositorio público."
read -rp "¿Quieres continuar? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo "Cancelado. No se han creado archivos.";
  exit 1
fi

read -rp "TELEGRAM_TOKEN (pon tu token, p. ej. 123:ABC...): " TELEGRAM_TOKEN
read -rp "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -rp "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
read -rp "S3_BUCKET: " S3_BUCKET
read -rp "S3_REGION (por defecto us-east-1): " S3_REGION
read -rp "PRESIGNED_EXPIRES (segundos, por defecto 3600): " PRESIGNED_EXPIRES
read -rp "MAX_ACCEPT_MB (MB, por defecto 2048): " MAX_ACCEPT_MB

# Valores por defecto
S3_REGION=${S3_REGION:-us-east-1}
PRESIGNED_EXPIRES=${PRESIGNED_EXPIRES:-3600}
MAX_ACCEPT_MB=${MAX_ACCEPT_MB:-2048}

ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
  read -rp ".env ya existe. ¿Sobrescribir? (s/n): " OVER
  if [[ "$OVER" != "s" && "$OVER" != "S" ]]; then
    echo "No se sobrescribió .env. Salida.";
    exit 0
  fi
fi

cat > "$ENV_FILE" <<EOF
TELEGRAM_TOKEN=${TELEGRAM_TOKEN}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
S3_BUCKET=${S3_BUCKET}
S3_REGION=${S3_REGION}
PRESIGNED_EXPIRES=${PRESIGNED_EXPIRES}
MAX_ACCEPT_MB=${MAX_ACCEPT_MB}
EOF

# Restriccion de permisos
chmod 600 "$ENV_FILE" || true

echo ".env creado correctamente — revisa su contenido y luego ejecuta:"
echo "  source .env  # o docker-compose up --build"

echo "RECUERDA: no subas .env al repositorio. Está en .gitignore por defecto."
