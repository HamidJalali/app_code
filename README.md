# app_code

A small Flask-based web application used as a sample service in a DevOps pipeline and container deployment workflow.

## Overview

This project provides a lightweight Python app with:

- a root endpoint returning a simple JSON message
- a health check endpoint for monitoring and readiness checks
- a Docker image definition for containerized deployment
- a Jenkins pipeline for building, scanning, and deploying the application

## Features

- Python 3.12 based container
- Flask API with JSON responses
- Health endpoint: `/health`
- Configurable HTTP port via environment variable
- Container-ready image with Gunicorn as production server

## Project Structure

```text
.
├── app.py              # Flask application entry point
├── Dockerfile          # Container definition
├── Jenkinsfile         # CI/CD pipeline for build and deployment
├── requirements.txt    # Python dependencies
├── VERSION             # Application version number
├── README.md           # Project documentation
```

## Application Endpoints

### GET /
Returns a welcome message and application status.

Example response:

```json
{
  "message": "Hello from the Python web app!",
  "status": "running"
}
```

### GET /health
Returns the health status of the service.

Example response:

```json
{
  "status": "healthy"
}
```

## Local Development

### Prerequisites

- Python 3.12+
- pip

### Install dependencies

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Run the app locally

```bash
python app.py
```

By default the application listens on port `8080`.

To override the port:

```bash
PORT=9090 python app.py
```

## Docker

### Build the image

```bash
docker build -t myapp .
```

### Run the container

```bash
docker run --rm -p 8080:8080 myapp
```

Then open:

- http://localhost:8080/
- http://localhost:8080/health

## CI/CD

The repository includes a `Jenkinsfile` that:

- checks out the app source
- reads the app version from `VERSION`
- logs in to the remote Docker registry
- builds the image remotely
- scans the image with Trivy
- pushes the image to the registry
- deploys the application using Kubernetes manifests from the related `app_config` repository

## Versioning

The current version is defined in the `VERSION` file and is used during the pipeline build process.

Example:

```text
1.0.0
```

## Notes

This project is designed as a small example of a containerized Python service in a CI/CD environment and can be extended for test automation, monitoring, or production deployment workflows.
