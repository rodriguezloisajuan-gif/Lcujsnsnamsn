# Telegram -> S3 Link Bot

Este bot recibe archivos (documentos/vídeos) enviados al bot, los sube a un bucket de S3 y devuelve un link pre-firmado.

IMPORTANTE: Si expusiste tu token en un chat público, revócalo en @BotFather y crea uno nuevo ahora.

Requisitos
- Python 3.8+
- Cuenta AWS con permiso de S3
- Bucket S3 creado

Archivos
- bot.py: código del bot
- requirements.txt: dependencias
- Dockerfile / docker-compose.yml: para ejecutar en contenedor
- .env.example: variables de entorno de ejemplo

Variables de entorno (usa .env o configuradas en Docker)
- TELEGRAM_TOKEN
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET
- S3_REGION (opcional, por defecto us-east-1)
- PRESIGNED_EXPIRES (segundos, por defecto 3600)
- MAX_ACCEPT_MB (límite máximo aceptado en MB, por defecto 2048)

Instalación y ejecución local
1. Copia `.env.example` a `.env` y completa las variables.
2. Crear entorno virtual e instalar:
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
3. Ejecutar:
   python bot.py

Con Docker
1. Construir:
   docker build -t tg-s3-bot .
2. Ejecutar con env en archivo .env:
   docker-compose up --build

Buenas prácticas
- Usa lifecycle rules en S3 para eliminar objetos antiguos automáticamente.
- Usa enlaces pre-firmados cortos si los archivos son privados.
- Para alta carga, mueve la subida a workers/colas (ej. Celery, SQS).
- No subas el archivo .env a repositorios públicos.

Soporte/Extensiones
- ¿Quieres que suba el repo a GitHub por ti? Dame el `owner/repo` existente y confirmación (ten en cuenta que no puedo crear repos nuevos).
- ¿Prefieres GCS/Dropbox en vez de S3? Lo adapto en seguida.
- ¿Quieres que lo haga con python-telegram-bot v20 (async)? También lo preparo.
