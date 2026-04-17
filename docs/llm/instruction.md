# Installing Qwen 3.5 9B Uncensored on Linux (CPU-only)

This document records the installation process for the Qwen 3.5 9B Uncensored model using Ollama on a Linux system with 24GB of RAM and no NVIDIA/AMD GPU.

## Prerequisites

- **OS:** Linux
- **RAM:** 8GB+ (24GB total on this system)
- **Disk:** ~7GB for the 4-bit quantized model

## Installation Steps

### 1. Install Ollama

Ollama is the easiest way to run local LLMs. Use the official installation script:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

After installation, the Ollama service starts automatically as a systemd service.

### 2. Pull Qwen 3.5 9B Uncensored

Use the `ollama pull` command to download the model:

```bash
ollama pull hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M
```

### 3. Verify Installation

Check the installed models:

```bash
ollama list
```

**Output:**
```
NAME                                          ID              SIZE      MODIFIED
hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M    ceef859d68e0    6.7 GB    Just now
```

## Running the Model

You can interact with the model via CLI:

```bash
ollama run hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M
```

Since no GPU was detected, Ollama will automatically run the model in CPU-only mode. Expect slower response times compared to GPU execution.

## Usage Guide

### Command Line Interface (CLI)
To start an interactive session:
```bash
ollama run hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M
```
While in the session, you can use:
- `/bye` to exit.
- `/?` to see available commands.

### REST API
Ollama provides a local API at `http://localhost:11434`. You can interact with it using `curl`:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M",
  "prompt": "Why is the sky blue?"
}'
```

### Model Lifecycle & RAM Management
Ollama automatically manages model loading to optimize RAM usage.
- **Cold Start:** The first request will trigger the model to load from disk, causing a short delay.
- **Auto-Unload:** By default, the model stays "hot" in RAM for **5 minutes** after your last interaction before being unloaded to free up system memory.
- **Immediate Unload (Free RAM):** To manually unload the model and free up RAM immediately:
  ```bash
  ollama stop hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M
  ```
- **Keep Alive:** You can control this behavior via the `keep_alive` parameter in API requests:
  - `"keep_alive": -1` (Stay loaded forever)
  - `"keep_alive": 0` (Unload immediately after response)
  - `"keep_alive": "1h"` (Keep loaded for 1 hour)

Example `curl` with `keep_alive`:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M",
  "prompt": "Hello",
  "keep_alive": -1
}'
```

## Service Management

Ollama runs as a background service managed by `systemd`.

- **Check Status:**
  ```bash
  systemctl status ollama
  ```
- **Stop Service:**
  ```bash
  sudo systemctl stop ollama
  ```
- **Start Service:**
  ```bash
  sudo systemctl start ollama
  ```
- **Restart Service:**
  ```bash
  sudo systemctl restart ollama
  ```

## Deletion and Cleanup

### Delete the Model
To remove the model and free up space:
```bash
ollama rm hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M
```

### Uninstall Ollama (Optional)
If you wish to remove Ollama entirely:
1. Stop and disable the service:
   ```bash
   sudo systemctl stop ollama
   sudo systemctl disable ollama
   ```
2. Remove the binary and service file:
   ```bash
   sudo rm $(which ollama)
   sudo rm /etc/systemd/system/ollama.service
   ```
3. Remove the model data and user:
   ```bash
   sudo rm -rf /usr/share/ollama
   sudo userdel ollama
   sudo groupdel ollama
   ```
