#!/bin/bash
# Start Ollama with correct binding for Docker container access

# Set binding to all interfaces (required for Docker containers to connect)
export OLLAMA_HOST=0.0.0.0:11434

echo "Starting Ollama with OLLAMA_HOST=$OLLAMA_HOST"
echo "This allows Docker containers to connect via host.docker.internal:11434"
echo ""

# Start Ollama
ollama serve
