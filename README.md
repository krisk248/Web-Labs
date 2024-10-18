# Web Tools Docker Environment

This project provides a Docker-based environment for web security testing and reconnaissance tools. It includes a variety of popular tools pre-installed and configured for ease of use.

## Features

- Pre-installed security tools and utilities
- Graphical application support (X11 forwarding)
- Persistent workspace volume
- Non-root user setup for improved security

## Prerequisites

- Docker
- Docker Compose
- X11 server (for GUI applications on Linux/macOS)

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/web-tools-docker.git
   cd web-tools-docker
   ```

2. Build and start the container:
   ```
   docker-compose up -d
   ```

3. Access the container:
   ```
   docker exec -it web_tools /bin/bash
   ```

## Available Tools

- **Reconnaissance**: subfinder, amass, nmap, httpx
- **Web Testing**: Burp Suite (1.7.36 and latest), Firefox, Chromium
- **Scanning & Fuzzing**: ffuf, feroxbuster, nuclei, naabu, whatweb, sqlmap, Arjun

## Usage

The tools are accessible from within the Docker container. Use the persistent workspace at `/home/webuser/workspace` to store your files and results.

Example usage:
```
subfinder -d example.com
nmap -p- example.com
burpsuite-new
```

## Customization

You can modify the `Dockerfile` to add or remove tools as needed. Remember to rebuild the Docker image after making changes:

```
docker-compose build
```

## Security Considerations

- The container runs with `NET_ADMIN` capabilities and `seccomp:unconfined`. Use with caution and only in controlled environments.
- Ensure you have permission to use these tools on your target systems.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)

## Disclaimer

This toolset is for educational and ethical testing purposes only. Do not use these tools against systems you do not own or have explicit permission to test.
