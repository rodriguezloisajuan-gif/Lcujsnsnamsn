#!/usr/bin/env bash
# entrypoint.sh
# Comprueba si pkg_resources está disponible y, si no, instala setuptools en el espacio de usuario
set -euo pipefail

# Muestra la versión de Python y del entorno para debugging
echo "Entry point: user=$(id -un) cwd=$(pwd) python=$(python --version 2>&1)"

# Intentar importar pkg_resources. Si falla, instalar setuptools localmente para el usuario.
python - <<'PY'
try:
    import pkg_resources
    print('pkg_resources OK', getattr(pkg_resources, '__version__', 'no-version'))
    raise SystemExit(0)
except Exception as e:
    print('pkg_resources no disponible, intentando instalar setuptools en --user:', e)
    raise SystemExit(1)
PY

if [ $? -ne 0 ]; then
  echo "Instalando setuptools y wheel en --user..."
  # Actualizar pip en el usuario y luego instalar setuptools/wheel en --user
  python -m pip install --upgrade --user pip setuptools wheel
  # Verificar de nuevo
  python - <<'PY'
try:
    import pkg_resources
    print('pkg_resources OK after user install', getattr(pkg_resources, '__version__', 'no-version'))
except Exception as e:
    print('ERROR: pkg_resources sigue sin estar disponible después de la instalación --user:', e)
    raise SystemExit(2)
PY
fi

# Ejecutar el bot como proceso PID 1
exec python bot.py
