#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 Testando Flutter Eval Compilation Server${NC}"
echo ""

# Teste 1: Health Check
echo -e "${YELLOW}[1/2] Health Check...${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:8081/health)
if echo "$HEALTH_RESPONSE" | grep -q "ok"; then
    echo -e "${GREEN}✓ Health check passou!${NC}"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo -e "${RED}✗ Health check falhou!${NC}"
    echo "   Response: $HEALTH_RESPONSE"
    exit 1
fi

echo ""

# Teste 2: Compilar widget simples
echo -e "${YELLOW}[2/2] Compilando widget de exemplo...${NC}"

CODE='import '\''package:flutter/material.dart'\'';

class HelloWidget extends StatelessWidget {
  const HelloWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('\''Hello from bytecode!'\'');
  }
}'

COMPILE_RESPONSE=$(curl -s -X POST http://localhost:8081/compile \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"$CODE\", \"lib\": \"hello\", \"className\": \"HelloWidget\"}")

if echo "$COMPILE_RESPONSE" | grep -q "bytecode"; then
    echo -e "${GREEN}✓ Compilação bem sucedida!${NC}"
    
    # Extrair informações
    SIZE=$(echo "$COMPILE_RESPONSE" | grep -o '"size":[0-9]*' | cut -d':' -f2)
    BYTECODE_LENGTH=$(echo "$COMPILE_RESPONSE" | grep -o '"bytecode":"[^"]*"' | wc -c)
    
    echo "   Bytecode size: $SIZE bytes"
    echo "   Base64 length: $BYTECODE_LENGTH caracteres"
else
    echo -e "${RED}✗ Compilação falhou!${NC}"
    echo "   Response: $COMPILE_RESPONSE"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
