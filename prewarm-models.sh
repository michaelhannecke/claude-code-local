#!/bin/bash
# Pre-warm Ollama models to avoid timeout on first Claude Code request

echo "Pre-warming qwen2.5-coder:14b..."
curl -s http://localhost:11434/api/generate -d '{"model":"qwen2.5-coder:14b","prompt":"hi","stream":false}' > /dev/null
echo "Done."

echo "Pre-warming qwen2.5-coder:7b..."
curl -s http://localhost:11434/api/generate -d '{"model":"qwen2.5-coder:7b","prompt":"hi","stream":false}' > /dev/null
echo "Done."

echo ""
echo "Models loaded and ready for Claude Code requests."
