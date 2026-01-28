#!/bin/sh

# Carrega variáveis do .env se existir
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Inicia o servidor
exec node server.js
