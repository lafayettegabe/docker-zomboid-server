# Project Zomboid Dedicated Server Automation

## Introduction

This project provides a fully automated setup for running a Project Zomboid dedicated server using a prebuilt Docker image. It simplifies server deployment, configuration, and mod management.

---

## Quick Start

1. Pull the Docker image from Docker Hub:
   ```bash
   docker pull lafayettegabe/docker-zomboid-server:latest
   ```

2. Create a `docker-compose.yml` file with the following content:
   ```yml
   services:
     zomboid-server:
       image: lafayettegabe/docker-zomboid-server:latest
       environment:
         - SERVER_NAME=DockerServer
         - SERVER_DESCRIPTION=A description for the server!
         - SERVER_PASSWORD=password
         - SERVER_MODS_COLLECTION_URL=https://steamcommunity.com/sharedfiles/filedetails/?id=3388931496
       ports:
         - "16261:16261/udp"
         - "16262:16262/udp"
       restart: unless-stopped
   ```

3. Start the server:
   ```bash
   docker-compose up -d
   ```

---

## Configuration

You can customize the server by setting the following environment variables in `docker-compose.yml`:

| Variable                   | Description                                   | Default Value               |
|----------------------------|-----------------------------------------------|-----------------------------|
| `SERVER_NAME`              | Public name of the server                    | `DockerServer`             |
| `SERVER_DESCRIPTION`       | Description displayed in the server browser  | `A description for the server!` |
| `SERVER_PASSWORD`          | Password to join the server                  | `password`                 |
| `SERVER_MODS_COLLECTION_URL` | URL to a Steam Workshop collection containing mods | `None`                     |

---

## Ports

Ensure the following ports are open on your host machine:

- **16261/udp**: Server connection.
- **16262/udp**: Game connection.

---

## License

This project is distributed under the MIT License.
