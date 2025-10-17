#!/bin/bash

# Script para executar o servidor em modo headless (sem interface gráfica)
# Uso: ./run_headless.sh

echo "🚀 Iniciando Flutter Eval Server em modo headless..."

cd "$(dirname "$0")"

# Verificar se xvfb está instalado
if ! command -v xvfb-run &> /dev/null; then
    echo "❌ Xvfb não encontrado!"
    echo "📦 Instalando Xvfb..."
    sudo apt-get update && sudo apt-get install xvfb -y
    
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao instalar Xvfb"
        exit 1
    fi
fi

echo "✅ Executando servidor headless (sem janela)..."
echo "📡 Servidor estará disponível em http://localhost:8081"
echo ""
echo "Para parar: Pressione Ctrl+C"
echo "════════════════════════════════════════════════════════"
echo ""

xvfb-run -a flutter run -d linux lib/main.dart
