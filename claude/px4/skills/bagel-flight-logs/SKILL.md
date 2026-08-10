---
name: bagel-flight-logs
description: Analyze PX4 flight logs (.ulg files) using the Bagel MCP server. Use when the user wants to inspect, query, or analyze ULog flight data.
allowed-tools: Bash, Read, Write
---

# Analyzing PX4 Flight Logs with Bagel MCP Server

Bagel is an MCP server that parses ULog data, builds Arrow tables, and runs DuckDB SQL queries to return structured results.

## Setup

### 1. Start the Bagel PX4 service

In a separate terminal:

```bash
cd ~/code/bagel
docker compose run --service-ports px4
```

Wait until you see:

```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 2. Place flight logs

Copy `.ulg` files into `~/code/bagel/logs/`. This directory is volume-mounted into the container at `/home/ubuntu/data`.

### 3. Connect Bagel to Claude Code (one-time)

```bash
claude mcp add --transport sse bagel http://0.0.0.0:8000/sse
```

Verify with `claude mcp get bagel`.

### 4. Increase MCP output token limit if needed

```bash
export MAX_MCP_OUTPUT_TOKENS=250000
```

## Available MCP Tools

- **describe_data_source** - Get metadata summary and available topics from a .ulg file
- **describe_topic** - Get detailed schema/structure of a specific topic
- **query_messages** - Run SQL queries against topic messages with optional time windowing
- **read_loggings** - Extract system log entries (INFO, WARN, ERROR) with timestamps
- **run_poml_capability** - Execute predefined analysis tasks

## How to Analyze a Log

1. Always reference log files by their **container path**: `/home/ubuntu/data/<filename>.ulg`
2. Start with `describe_data_source` to see what topics and metadata are available
3. Use `describe_topic` to understand the schema of topics you want to query
4. Use `query_messages` with SQL to extract and analyze specific data
5. Use `read_loggings` to check for warnings/errors during the flight

## Example Prompts

- "Summarize the metadata of /home/ubuntu/data/my_flight.ulg"
- "What's the correlation between voltage and current in battery_status?"
- "Show me the attitude data during the first 30 seconds of flight"
- "Were there any error or warning log messages?"
- "Can you help me tune the PID of my drone based on this log?"
