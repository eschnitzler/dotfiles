#!/usr/bin/env python3
"""
LSP wrapper that translates file paths between host and Docker container.
Proxies LSP communication to djlsp running inside Docker with path translation.
"""
import sys
import json
import subprocess
import os
import re

# Path translation configuration
# Detect the project root from the current working directory
HOST_ROOT = os.getcwd()
CONTAINER_ROOT = "/app"


def translate_host_to_container(text):
    """Translate host paths to container paths in text."""
    # Replace file:// URIs
    text = text.replace(f"file://{HOST_ROOT}", f"file://{CONTAINER_ROOT}")
    # Replace plain paths in JSON strings
    text = text.replace(f'"{HOST_ROOT}', f'"{CONTAINER_ROOT}')
    return text


def translate_container_to_host(text):
    """Translate container paths to host paths in text."""
    # Replace file:// URIs
    text = text.replace(f"file://{CONTAINER_ROOT}", f"file://{HOST_ROOT}")
    # Replace plain paths in JSON strings
    text = text.replace(f'"{CONTAINER_ROOT}', f'"{HOST_ROOT}')
    return text


def read_message(stream):
    """Read a JSON-RPC message from stream."""
    headers = {}
    while True:
        line = stream.readline()
        if not line:
            return None
        line = line.decode('utf-8').strip()
        if not line:
            break
        key, value = line.split(": ", 1)
        headers[key] = value

    content_length = int(headers.get("Content-Length", 0))
    if content_length == 0:
        return None

    content = stream.read(content_length)
    return content  # Return bytes


def write_message(stream, content):
    """Write a JSON-RPC message to stream."""
    if isinstance(content, str):
        content_bytes = content.encode("utf-8")
    else:
        content_bytes = content
    stream.write(f"Content-Length: {len(content_bytes)}\r\n\r\n".encode("utf-8"))
    stream.write(content_bytes)
    stream.flush()


def main():
    # Start djlsp inside Docker
    cmd = [
        "docker", "compose", "exec", "-T", "web",
        "poetry", "run", "djlsp"
    ]

    try:
        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=sys.stderr,
            cwd=HOST_ROOT
        )
    except Exception as e:
        print(f"Error starting djlsp: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        # Read from stdin (Neovim), translate, write to Docker
        import threading

        def stdin_to_docker():
            """Forward messages from Neovim to Docker with path translation."""
            while True:
                message = read_message(sys.stdin.buffer)
                if message is None:
                    break

                # Translate host paths to container paths
                translated = translate_host_to_container(message.decode("utf-8"))

                # Write to Docker
                write_message(process.stdin, translated)

        def docker_to_stdout():
            """Forward messages from Docker to Neovim with path translation."""
            while True:
                message = read_message(process.stdout)
                if message is None:
                    break

                # Translate container paths to host paths
                translated = translate_container_to_host(message.decode("utf-8"))

                # Write to stdout (Neovim)
                write_message(sys.stdout.buffer, translated)

        # Start forwarding threads
        t1 = threading.Thread(target=stdin_to_docker, daemon=True)
        t2 = threading.Thread(target=docker_to_stdout, daemon=True)
        t1.start()
        t2.start()

        # Wait for process to exit
        process.wait()

    except KeyboardInterrupt:
        process.terminate()
        process.wait()


if __name__ == "__main__":
    main()
