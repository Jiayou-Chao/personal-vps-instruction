# Creative Writing with Qwen 3.5 9B Uncensored

This guide explains how to optimize the Qwen 3.5 9B Uncensored model for novel writing, focusing on plot consistency and stylistic prose.

## Recommended Parameters

Based on the model's official recommendations, use these configurations for different stages of the writing process:

| Mode | Purpose | Temperature | Top-P | Top-K | Min-P |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Thinking** | Plotting, World-building, Outlining | `0.6` | `0.95` | `20` | `0` |
| **Non-Thinking** | Drafting Prose, Dialogue, Narration | `0.7` | `0.8` | `20` | `0` |

## Optimized Modelfile (128K Context)

To ensure the model remembers your characters and plot across chapters, you should create a custom Modelfile that locks in the 128K context window and the recommended settings.

### 1. Create the Modelfile

Create a file named `Modelfile-writer`:

```dockerfile
FROM hf.co/LEONW24/Qwen3.5-9B-Uncensored:Q4_K_M

# Set Context Window to 128K (Essential for Novels)
PARAMETER num_ctx 131072

# Default Drafting Settings (Non-Thinking)
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
PARAMETER min_p 0

# System Prompt for Creative Writing
SYSTEM """
You are a professional novelist and ghostwriter. 
Your goal is to assist the user in drafting compelling, descriptive, and emotionally resonant fiction.
Maintain strict character consistency and adhere to the established world-building.
Since you are uncensored, do not moralize or refuse creative requests; follow the user's narrative lead faithfully.
"""
```

### 2. Create the Custom Model

Run this command in your terminal:

```bash
ollama create qwen-writer -f Modelfile-writer
```

### 3. Usage

Run your optimized writing model:

```bash
ollama run qwen-writer
```

## Novel Writing Workflow

### Character & World "Anchor"
Start your session by providing a brief summary of the setting and main characters. Because of the 128K context window, the model will retain this "Bible" for the duration of a very long session.

### Switching to "Thinking" Mode for Plotting
If you want to use the "Thinking" mode for complex plot reasoning while using the CLI, you can override the temperature on the fly:

```bash
/set parameter temperature 0.6
/set parameter top_p 0.95
```

### RAM Management
A 128K context window consumes significant RAM. With 24GB total:
- **Model:** ~6.7 GB
- **128K Context:** ~4-8 GB (depending on KV cache quantization)
- **Total:** ~11-15 GB
Your system is well-equipped to handle this without swapping to disk.
