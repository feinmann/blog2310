# Model Context Protocol (MCP): A Complete Guide
3atthias 3erger
2025-05-25

## Introduction

The Model Context Protocol (MCP) is a standardized communication
protocol designed to enable AI models to interact with external systems,
tools, and data sources in a consistent and secure manner. MCP acts as a
bridge between AI models and the broader digital ecosystem, allowing
models to access real-time information, execute commands, and integrate
with various applications. Further information on
https://github.com/modelcontextprotocol

MCP addresses the fundamental challenge of AI models being limited to
their training data by providing a structured way to extend their
capabilities through external resources. This protocol enables models to
perform tasks like web searches, database queries, file operations, and
API calls while maintaining security and reliability.

## Core Concepts

### Protocol Architecture

MCP follows a client-server architecture where:

- **MCP Server**: Provides resources, tools, and capabilities to AI
  models
- **MCP Client**: Consumes these capabilities (typically the AI model or
  its host application)
- **Transport Layer**: Handles communication between client and server
  (HTTP, WebSocket, or local transport)

### Key Components

**Resources**: Static or dynamic data sources that models can access
(files, databases, APIs)

**Tools**: Executable functions that models can invoke to perform
actions

**Prompts**: Pre-defined templates that help structure model
interactions

**Sampling**: Methods for the server to request completions from the
client

## Installation and Setup

### Prerequisites

Before installing MCP, ensure you have the following prerequisites on
your Arch Linux system:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo pacman -S python python-pip nodejs npm git
```

</div>

### Installing MCP SDK

The official MCP SDK can be installed using pip:

<div class="code-with-filename">

**Terminal**

``` bash
$ pip install mcp-context-sdk
```

</div>

For development purposes, you might also want to install the
TypeScript/JavaScript SDK:

<div class="code-with-filename">

**Terminal**

``` bash
$ npm install @modelcontextprotocol/sdk
```

</div>

### Setting Up Your First MCP Server

Create a basic MCP server using Python:

<div class="code-with-filename">

**Terminal**

``` bash
$ uv init mcp-tutorial && cd mcp-tutorial
$ uv venv
$ source .venv/bin/activate.fish
$ uv pip install mcp-context-sdk
```

</div>

Create a simple server file:

``` python
# server.py
import asyncio
from mcp import Server, types
from mcp.server import NotificationOptions, ServerOptions
from mcp.server.models import InitializationOptions

server = Server("example-server")

@server.list_resources()
async def handle_list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri="file://example.txt",
            name="Example Resource",
            description="A simple example resource",
            mimeType="text/plain"
        )
    ]

@server.read_resource()
async def handle_read_resource(uri: str) -> str:
    if uri == "file://example.txt":
        return "Hello from MCP server!"
    raise ValueError(f"Unknown resource: {uri}")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="echo",
            description="Echo back the input text",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {"type": "string"}
                },
                "required": ["text"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "echo":
        text = arguments.get("text", "")
        return [types.TextContent(type="text", text=f"Echo: {text}")]
    raise ValueError(f"Unknown tool: {name}")

async def main():
    from mcp.server.stdio import stdio_server
    
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="example-server",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={}
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())
```

Run the server:

<div class="code-with-filename">

**Terminal**

``` bash
$ python server.py
```

</div>

## Creating MCP Resources

Resources in MCP represent data that AI models can access. They can be
static files, dynamic content, or real-time data streams.

### File Resources

``` python
@server.list_resources()
async def handle_list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri="file://config.json",
            name="Configuration",
            description="Application configuration file",
            mimeType="application/json"
        ),
        types.Resource(
            uri="file://logs/app.log",
            name="Application Logs",
            description="Recent application logs",
            mimeType="text/plain"
        )
    ]

@server.read_resource()
async def handle_read_resource(uri: str) -> str:
    if uri == "file://config.json":
        return '{"debug": true, "port": 8080}'
    elif uri == "file://logs/app.log":
        return "2025-05-25 10:00:00 - Application started\n2025-05-25 10:01:00 - Processing request"
    raise ValueError(f"Resource not found: {uri}")
```

### Dynamic Resources

``` python
import datetime
import json

@server.list_resources()
async def handle_list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri="dynamic://system-status",
            name="System Status",
            description="Current system status and metrics",
            mimeType="application/json"
        )
    ]

@server.read_resource()
async def handle_read_resource(uri: str) -> str:
    if uri == "dynamic://system-status":
        status = {
            "timestamp": datetime.datetime.now().isoformat(),
            "cpu_usage": "15%",
            "memory_usage": "8.2GB/16GB",
            "disk_usage": "45%",
            "status": "healthy"
        }
        return json.dumps(status, indent=2)
    raise ValueError(f"Resource not found: {uri}")
```

## Implementing MCP Tools

Tools allow AI models to perform actions and execute functions through
the MCP server.

### Basic Tools

``` python
@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="calculate",
            description="Perform basic mathematical calculations",
            inputSchema={
                "type": "object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": "Mathematical expression to evaluate"
                    }
                },
                "required": ["expression"]
            }
        ),
        types.Tool(
            name="timestamp",
            description="Get current timestamp",
            inputSchema={
                "type": "object",
                "properties": {
                    "format": {
                        "type": "string",
                        "description": "Timestamp format (iso, unix, readable)",
                        "default": "iso"
                    }
                }
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "calculate":
        expression = arguments.get("expression", "")
        try:
            # Simple evaluation - in production, use a safer math parser
            result = eval(expression)
            return [types.TextContent(type="text", text=str(result))]
        except Exception as e:
            return [types.TextContent(type="text", text=f"Error: {str(e)}")]
    
    elif name == "timestamp":
        format_type = arguments.get("format", "iso")
        now = datetime.datetime.now()
        
        if format_type == "unix":
            result = str(int(now.timestamp()))
        elif format_type == "readable":
            result = now.strftime("%Y-%m-%d %H:%M:%S")
        else:  # iso
            result = now.isoformat()
        
        return [types.TextContent(type="text", text=result)]
    
    raise ValueError(f"Unknown tool: {name}")
```

### Advanced Tools with External APIs

``` python
import aiohttp

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="weather",
            description="Get current weather information",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "City name"
                    },
                    "units": {
                        "type": "string",
                        "description": "Temperature units (metric, imperial)",
                        "default": "metric"
                    }
                },
                "required": ["city"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "weather":
        city = arguments.get("city", "")
        units = arguments.get("units", "metric")
        
        # Note: Replace with your actual API key
        api_key = "your_openweather_api_key"
        url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&units={units}&appid={api_key}"
        
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                if response.status == 200:
                    data = await response.json()
                    weather_info = f"Weather in {city}: {data['weather'][0]['description']}, "
                    weather_info += f"Temperature: {data['main']['temp']}°"
                    weather_info += "C" if units == "metric" else "F"
                    return [types.TextContent(type="text", text=weather_info)]
                else:
                    return [types.TextContent(type="text", text=f"Failed to get weather for {city}")]
    
    raise ValueError(f"Unknown tool: {name}")
```

## MCP Client Implementation

Creating a client to interact with MCP servers:

``` python
# client.py
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    server_params = StdioServerParameters(
        command="python",
        args=["server.py"]
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize the connection
            await session.initialize()
            
            # List available resources
            resources = await session.list_resources()
            print("Available resources:")
            for resource in resources.resources:
                print(f"  - {resource.name}: {resource.uri}")
            
            # List available tools
            tools = await session.list_tools()
            print("\nAvailable tools:")
            for tool in tools.tools:
                print(f"  - {tool.name}: {tool.description}")
            
            # Call a tool
            result = await session.call_tool("echo", {"text": "Hello MCP!"})
            print(f"\nTool result: {result.content[0].text}")
            
            # Read a resource
            content = await session.read_resource("file://example.txt")
            print(f"\nResource content: {content.contents[0].text}")

if __name__ == "__main__":
    asyncio.run(main())
```

Run the client:

<div class="code-with-filename">

**Terminal**

``` bash
$ python client.py
```

</div>

## Configuration and Transport Options

### HTTP Transport

For HTTP-based MCP servers:

``` python
from mcp.server.fastapi import create_app
from fastapi import FastAPI
import uvicorn

app: FastAPI = create_app(server)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

Start the HTTP server:

<div class="code-with-filename">

**Terminal**

``` bash
$ pip install fastapi uvicorn
$ python http_server.py
```

</div>

### WebSocket Transport

``` python
from mcp.server.websocket import websocket_server
import websockets

async def main():
    async with websocket_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, initialization_options)

# Run with websockets
async def serve():
    await websockets.serve(main, "localhost", 8765)

if __name__ == "__main__":
    asyncio.run(serve())
```

## Security and Best Practices

### Authentication and Authorization

``` python
from mcp.server.models import InitializationOptions

class SecureMCPServer:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.server = Server("secure-server")
    
    def validate_request(self, headers: dict) -> bool:
        return headers.get("Authorization") == f"Bearer {self.api_key}"
    
    @server.call_tool()
    async def handle_call_tool(self, name: str, arguments: dict, meta: dict) -> list[types.TextContent]:
        if not self.validate_request(meta.get("headers", {})):
            raise PermissionError("Invalid authentication")
        
        # Tool implementation here
        pass
```

### Input Validation

``` python
from pydantic import BaseModel, ValidationError

class CalculatorInput(BaseModel):
    expression: str
    max_length: int = 100

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "calculate":
        try:
            input_data = CalculatorInput(**arguments)
            if len(input_data.expression) > input_data.max_length:
                raise ValueError("Expression too long")
            
            # Safe calculation logic here
            pass
        except ValidationError as e:
            return [types.TextContent(type="text", text=f"Validation error: {e}")]
```

### Rate Limiting

<div class="code-with-filename">

**Terminal**

``` bash
$ pip install aioredis
```

</div>

``` python
import aioredis
from datetime import datetime, timedelta

class RateLimiter:
    def __init__(self, redis_url: str = "redis://localhost"):
        self.redis = aioredis.from_url(redis_url)
    
    async def check_rate_limit(self, client_id: str, limit: int = 100) -> bool:
        key = f"rate_limit:{client_id}:{datetime.now().strftime('%Y-%m-%d:%H')}"
        current = await self.redis.get(key)
        
        if current is None:
            await self.redis.setex(key, 3600, 1)
            return True
        elif int(current) < limit:
            await self.redis.incr(key)
            return True
        else:
            return False
```

## Testing MCP Implementations

### Unit Testing

Create test files for your MCP server:

``` python
# test_server.py
import pytest
import asyncio
from mcp import types
from server import server

@pytest.mark.asyncio
async def test_list_resources():
    resources = await server.handle_list_resources()
    assert len(resources) > 0
    assert any(r.name == "Example Resource" for r in resources)

@pytest.mark.asyncio
async def test_echo_tool():
    result = await server.handle_call_tool("echo", {"text": "test"})
    assert len(result) == 1
    assert result[0].text == "Echo: test"

@pytest.mark.asyncio
async def test_read_resource():
    content = await server.handle_read_resource("file://example.txt")
    assert content == "Hello from MCP server!"
```

Run tests:

<div class="code-with-filename">

**Terminal**

``` bash
$ pip install pytest pytest-asyncio
$ pytest test_server.py -v
```

</div>

### Integration Testing

``` python
# test_integration.py
import asyncio
import subprocess
import time
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

@pytest.mark.asyncio
async def test_full_server_client_interaction():
    server_params = StdioServerParameters(
        command="python",
        args=["server.py"]
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # Test resource listing
            resources = await session.list_resources()
            assert len(resources.resources) > 0
            
            # Test tool calling
            result = await session.call_tool("echo", {"text": "integration test"})
            assert "integration test" in result.content[0].text
```

## Deployment and Production

### Docker Deployment

Create a Dockerfile:

``` dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "http_server.py"]
```

Build and run:

<div class="code-with-filename">

**Terminal**

``` bash
$ docker build -t mcp-server .
$ docker run -p 8000:8000 mcp-server
```

</div>

### Systemd Service

Create a systemd service file:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo tee /etc/systemd/system/mcp-server.service > /dev/null << EOF
[Unit]
Description=MCP Server
After=network.target

[Service]
Type=simple
User=mcp
WorkingDirectory=/opt/mcp-server
ExecStart=/opt/mcp-server/venv/bin/python server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

</div>

Enable and start the service:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo systemctl daemon-reload
$ sudo systemctl enable mcp-server
$ sudo systemctl start mcp-server
$ sudo systemctl status mcp-server
```

</div>

## Shell Comparison: Fish vs Bash

### Bash Usage

In Bash, MCP development typically involves these common patterns:

<div class="code-with-filename">

**Terminal**

``` bash
$ export MCP_SERVER_URL="http://localhost:8000"
$ python -m venv mcp_env && source mcp_env/bin/activate
$ pip install mcp-sdk
$ python server.py &
$ SERVER_PID=$!
$ echo "Server started with PID: $SERVER_PID"
```

</div>

Environment variable management in Bash:

<div class="code-with-filename">

**Terminal**

``` bash
$ cat > .env << EOF
MCP_SERVER_PORT=8000
MCP_DEBUG=true
MCP_API_KEY=your_secret_key
EOF
$ source .env
```

</div>

### Fish Shell Usage

Fish shell offers more intuitive syntax and better autocompletion:

<div class="code-with-filename">

**Terminal**

``` bash
$ set -x MCP_SERVER_URL "http://localhost:8000"
$ python -m venv mcp_env; and source mcp_env/bin/activate.fish
$ pip install mcp-sdk
$ python server.py &
$ set SERVER_PID (jobs -l | tail -n1 | awk '{print $2}')
$ echo "Server started with PID: $SERVER_PID"
```

</div>

Environment variable management in Fish:

<div class="code-with-filename">

**Terminal**

``` bash
$ cat > config.fish << EOF
set -x MCP_SERVER_PORT 8000
set -x MCP_DEBUG true
set -x MCP_API_KEY your_secret_key
EOF
$ source config.fish
```

</div>

Fish provides better error handling and more readable syntax:

<div class="code-with-filename">

**Terminal**

``` bash
$ function start_mcp_server
    if test -f server.py
        python server.py &
        set -g MCP_SERVER_PID (jobs -l | tail -n1 | awk '{print $2}')
        echo "MCP Server started with PID: $MCP_SERVER_PID"
    else
        echo "Error: server.py not found"
        return 1
    end
end
```

</div>

Key differences: - Fish uses `set -x` instead of `export` for
environment variables - Fish has better built-in functions and more
intuitive syntax - Fish provides superior autocompletion for MCP
commands and arguments - Fish uses `and` and `or` instead of `&&` and
`||` - Fish functions are more readable and easier to debug

## Troubleshooting Common Issues

### Connection Issues

<div class="code-with-filename">

**Terminal**

``` bash
$ # Check if MCP server is running
$ netstat -tuln | grep 8000
$ # Or use ss on modern systems
$ ss -tuln | grep 8000
```

</div>

### Debug Mode

Enable debug logging:

``` python
import logging
logging.getLogger("mcp").setLevel(logging.DEBUG)
```

### Performance Monitoring

<div class="code-with-filename">

**Terminal**

``` bash
$ pip install prometheus-client
$ python -m prometheus_client.start_http_server 8001
```

</div>

## Interesting Fact

The Model Context Protocol was designed with inspiration from the
Language Server Protocol (LSP) used in code editors. Just as LSP allows
any editor to support any programming language through a standardized
protocol, MCP allows any AI model to interact with any external system
through a unified interface. This design philosophy enables incredible
extensibility - a single MCP server can potentially serve multiple AI
models simultaneously, and a single AI model can interact with dozens of
different MCP servers, creating a rich ecosystem of AI-enhanced
applications.

The protocol’s name itself reflects its core purpose: providing
“context” to AI models beyond their training data, enabling them to
operate in real-time environments with access to current information and
dynamic capabilities.
