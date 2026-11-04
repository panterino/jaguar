#!/bin/sh
# Prueba la nube de Jaguar de punta a punta: levanta los emuladores de Firebase
# (Authentication y Firestore, con las reglas de firestore.rules) y corre las
# pruebas del cliente REST contra ellos. Hace falta Java y firebase-tools.
#   tool/probar_nube.sh
set -e
cd "$(dirname "$0")/.."
firebase emulators:exec --only firestore,auth --project demo-jaguar \
  "cd apps/jaguar && flutter test test/cloud/rest_backend_emulator_test.dart"
