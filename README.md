# Claude Code Local

> Run [Claude Code](https://claude.ai/code) with local LLMs on Apple Silicon using Ollama and LiteLLM.

[![Platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-blue)](#prerequisites)
[![Docker](https://img.shields.io/badge/docker-required-blue)](#prerequisites)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

## Overview

This project provides configuration files to run Claude Code CLI against local Ollama models via a LiteLLM proxy. All inference runs locally on your Mac using Metal GPU acceleration.

**Key Benefits:**

- Fully offline operation
- No API costs
- Data stays on your machine
- Metal GPU acceleration on Apple Silicon

## Architecture

```text
┌─────────────────────────────────────────────────────────┐
│                   Host (Apple Silicon Mac)              │
├─────────────────────────────────────────────────────────┤
│  Ollama (native)                                        │
│  └── Port 11434 ← Metal GPU acceleration                │
│                                                         │
│  Docker Network (claude-local-network)                  │
│  ├── LiteLLM Proxy :4000 ← API translation              │
│  └── DevContainer        ← Claude Code CLI              │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

| Requirement | Description |
|-------------|-------------|
| [Ollama](https://ollama.ai) | Local LLM runtime (install natively) |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Container runtime |
| [VS Code](https://code.visualstudio.com/) | With [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension |

## Quick Start

```bash
# 1. Pull a model
ollama pull qwen2.5-coder:7b

# 2. Start Ollama with Docker-accessible binding
./start-ollama.sh

# 3. Start LiteLLM proxy
docker compose up -d

# 4. Open in VS Code DevContainer, then run:
claude
```

## Model Mapping

Claude Code model requests are translated to local Ollama models:

| Claude Model | Ollama Model | RAM Required |
|--------------|--------------|--------------|
| `claude-3-5-haiku-*` | `qwen2.5-coder:7b` | ~4.5 GB |
| `claude-3-5-sonnet-*` | `qwen2.5-coder:14b` | ~9 GB |
| `claude-3-opus-*` | `qwen2.5-coder:14b` | ~9 GB |

> **Tip:** On 16GB Macs, edit `litellm_config.yaml` to map all models to the 7b variant.

## Setup Guide

### 1. Pull Ollama Models

For full model support:

```bash
ollama pull qwen2.5-coder:14b
ollama pull qwen2.5-coder:7b
```

For limited RAM (7b only):

```bash
ollama pull qwen2.5-coder:7b
```

### 2. Start Ollama

Ollama must bind to `0.0.0.0` for Docker containers to connect.

```bash
# Stop existing Ollama service if running
pkill ollama

# Start with correct binding
./start-ollama.sh

# Or manually:
# export OLLAMA_HOST=0.0.0.0:11434
# ollama serve
```

Verify:

```bash
curl http://localhost:11434/api/tags
```

### 3. Start LiteLLM Proxy

```bash
docker compose up -d
```

Verify:

```bash
curl -H "Authorization: Bearer sk-local-dev-key" http://localhost:4000/health
```

### 4. Pre-warm Models (Optional)

Avoid cold-start timeout on first request:

```bash
./prewarm-models.sh
```

### 5. Open DevContainer

> **Note:** Complete steps 2-3 first. The DevContainer requires the `claude-local-network` created by `docker compose up`.

1. Open this folder in VS Code
2. Press `Cmd+Shift+P`
3. Select "Dev Containers: Reopen in Container"
4. Run `claude` in the terminal

## Project Structure

```text
.
├── .devcontainer/
│   └── devcontainer.json    # DevContainer with Claude Code pre-installed
├── docker-compose.yaml      # LiteLLM container configuration
├── litellm_config.yaml      # Model aliases and routing
├── start-ollama.sh          # Start Ollama with correct binding
└── prewarm-models.sh        # Load models into RAM
```

## Configuration

### Environment Variables

The DevContainer automatically sets these for Claude Code:

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_BASE_URL` | `http://litellm:4000/anthropic` | LiteLLM endpoint |
| `ANTHROPIC_AUTH_TOKEN` | `sk-local-dev-key` | Auth token (matches `master_key`) |

### Customization

Edit `litellm_config.yaml` to:

- Change model mappings (use different Ollama models)
- Adjust request timeouts
- Add cloud API fallback routing

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Connection refused" from LiteLLM | Ollama bound to localhost only | Run `./start-ollama.sh` or set `OLLAMA_HOST=0.0.0.0:11434` |
| Timeout on first request | Models load lazily | Run `./prewarm-models.sh` after starting Ollama |
| Out of memory | 14B models need ~12GB RAM | Use 7b models or close other apps |
| DevContainer fails to start | Docker network missing | Run `docker compose up -d` first |

## License

MIT
