# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a FastAPI sample application designed to run on AWS Lambda with HTTP API Gateway. The project uses **uv** for Python package management and **Terraform** for infrastructure management.

## Architecture

- **FastAPI Application** (`src/main.py`): Main API with 4 endpoints using in-memory storage
- **Lambda Handler** (`src/lambda_handler.py`): Mangum adapter to convert ASGI (FastAPI) to AWS Lambda format
- **Terraform Infrastructure** (`terraform/`): HTTP API Gateway + Lambda function deployment
- **Build & Deploy Scripts** (`scripts/`): Automated build and deployment workflows

## Core Components

### FastAPI Application Structure
- `src/main.py`: Main FastAPI app with item management endpoints
- `src/models.py`: Pydantic models for Item, ItemCreate, and HealthResponse
- `src/lambda_handler.py`: Mangum wrapper for Lambda compatibility

### Infrastructure (Terraform)
- Uses **HTTP API Gateway** (not REST API) for cost efficiency and performance
- Lambda function with Python 3.9 runtime
- CloudWatch logging enabled
- CORS configured for all origins

## Essential Commands

### Development
```bash
# Install dependencies
uv sync

# Run local development server
uv run uvicorn src.main:app --reload

# Code formatting
uv run black src/

# Linting
uv run ruff src/

# Testing
uv run pytest
```

### Build & Deploy
```bash
# Build Lambda package
./scripts/build.sh

# Deploy to AWS (interactive)
./scripts/deploy.sh [environment] [aws-region]

# Terraform operations
cd terraform
terraform init
terraform plan
terraform apply
terraform destroy
```

## Important Configuration

### Package Management
- Uses **uv** (not pip/poetry) for dependency management
- Dependencies defined in `pyproject.toml`
- Build script creates zip package with dependencies for Lambda

### AWS Configuration
- Requires AWS CLI configured with appropriate permissions
- Default region: ap-northeast-1
- Lambda settings: 512MB memory, 30s timeout
- Uses HTTP API Gateway (v2) for better performance and cost

### Environment Variables
Configure in `terraform/variables.tf`:
- `aws_region`: Deployment region
- `project_name`: Resource naming prefix  
- `environment`: Environment name (dev/staging/prod)

## API Endpoints
- `GET /`: Health check
- `GET /items`: List all items
- `GET /items/{item_id}`: Get specific item
- `POST /items`: Create new item

## Development Notes

- FastAPI app uses in-memory storage (not persistent)
- Mangum adapter handles FastAPI to Lambda conversion
- HTTP API Gateway provides simpler configuration than REST API
- Build script handles dependency packaging for Lambda deployment
- All scripts include error handling and package size validation