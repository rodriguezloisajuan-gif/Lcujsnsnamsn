#!/usr/bin/env python3
import os
import tempfile
import logging
import boto3
from telegram import Update
from telegram.ext import Updater, MessageHandler, Filters, CallbackContext, CommandHandler

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# CONFIG via environment variables (no token hardcoded)
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET = os.getenv("AWS_SECRET_ACCESS_KEY")
S3_BUCKET = os.getenv("S3_BUCKET")
S3_REGION = os.getenv("S3_REGION", "us-east-1")
PRESIGNED_EXPIRES = int(os.getenv("PRESIGNED_EXPIRES", "3600"))  # segundos
MAX_ACCEPT_MB = int(os.getenv("MAX_ACCEPT_MB", "2048"))  # tamaño que aceptamos subir (por seguridad)

if not TELEGRAM_TOKEN:
    logger.error("TELEGRAM_TOKEN no configurado. Salir.")
    raise SystemExit(1)
if not S3_BUCKET:
    logger.error("S3_BUCKET no configurado. Salir.")
    raise SystemExit(1)

s3 = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET,
    region_name=S3_REGION,
)

def start(update: Update, context: CallbackContext):
    update.message.reply_text(
        "Hola. Envíame un archivo (document/video). Si pesa mucho, lo subiré a S3 y te daré un link de descarga. /help para más info."
    )

def help_cmd(update: Update, context: CallbackContext):
    update.message.reply_text(
        "Envía un archivo como 'document' o 'video'. El bot lo descargará de Telegram, lo subirá a S3 y te devolverá un link pre-firmado."
    )

def handle_document_or_video(update: Update, context: CallbackContext):
    msg = update.message

    # soporta document y video
    doc = msg.document or getattr(msg, "video", None) or getattr(msg, "video_note", None)
    if not doc:
        update.message.reply_text("No encontré un archivo válido en el mensaje.")
        return

    size_mb = (doc.file_size / (1024 * 1024)) if getattr(doc, "file_size", None) else None
    if size_mb:
        logger.info("Archivo recibido: %s MB", f"{size_mb:.1f}")

    # Si el archivo es demasiado grande (evitamos subir > MAX_ACCEPT_MB)
    if size_mb and size_mb > MAX_ACCEPT_MB:
        update.message.reply_text(
            f"El archivo pesa {size_mb:.1f} MB y supera el límite configurado de {MAX_ACCEPT_MB} MB. Contacta al administrador."
        )
        return

    update.message.reply_text("Recibido. Voy a subir el archivo a almacenamiento externo y te daré el link cuando termine...")

    tmp_path = None
    try:
        tg_file = doc.get_file(timeout=120)

        # Descarga a fichero temporal en disco (evita usar memoria)
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp_path = tmp.name
        logger.info("Descargando archivo temporal a %s", tmp_path)
        tg_file.download(custom_path=tmp_path)

        # Nombre de objeto en S3
        file_name = getattr(doc, "file_name", None) or getattr(doc, "file_unique_id", "file")
        # sanitizar nombre simple
        safe_name = file_name.replace(" ", "_")
        key = f"uploads/{doc.file_unique_id}_{safe_name}"

        # Subida (upload_file usa multipart cuando es necesario)
        logger.info("Subiendo a S3: s3://%s/%s", S3_BUCKET, key)
        s3.upload_file(tmp_path, S3_BUCKET, key, ExtraArgs={"ContentType": getattr(doc, "mime_type", "application/octet-stream")})

        # Generar URL pre-firmado
        url = s3.generate_presigned_url(
            "get_object", Params={"Bucket": S3_BUCKET, "Key": key}, ExpiresIn=PRESIGNED_EXPIRES
        )

        reply = f"Archivo subido correctamente."
        if size_mb:
            reply += f" Tamaño: {size_mb:.1f} MB\n"
        reply += f"Link de descarga (válido {PRESIGNED_EXPIRES} s):\n{url}"
        update.message.reply_text(reply)
    except Exception as e:
        logger.exception("Error procesando archivo")
        update.message.reply_text(f"Error al subir/obtener link: {e}")
    finally:
        if tmp_path:
            try:
                os.remove(tmp_path)
            except Exception:
                pass

def main():
    updater = Updater(TELEGRAM_TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("help", help_cmd))
    # manejar documentos y vídeos
    dp.add_handler(MessageHandler(Filters.document | Filters.video | Filters.video_note, handle_document_or_video))

    updater.start_polling()
    logger.info("Bot iniciado. Esperando mensajes...")
    updater.idle()

if __name__ == "__main__":
    main()
