# Crear workflow que construye la imagen Docker (opcional) y la sube a GitHub Packages
# Este workflow NO contiene secretos; debes añadir los secretos en Settings -> Secrets:
# - DOCKERHUB_USERNAME (si usas Docker Hub)
# - DOCKERHUB_TOKEN
# - TELEGRAM_TOKEN
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# Si no quieres publicar la imagen, el job "build" solo construye la imagen.
