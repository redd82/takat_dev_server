# Python Development Environment Setup

## Python Environment Management

### 1. Virtual Environment Setup

#### Using venv (built-in)
```bash
# Navigate to your project directory
cd ~/projects/myproject

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Deactivate when done
deactivate
```

#### Using Poetry (recommended)
```bash
# Initialize new project
poetry new myproject
cd myproject

# Or initialize in existing directory
cd ~/projects/existing-project
poetry init

# Install dependencies
poetry install

# Add new dependency
poetry add requests fastapi uvicorn

# Add development dependency
poetry add --group dev pytest black flake8 mypy

# Activate shell
poetry shell

# Run commands in environment
poetry run python main.py
poetry run pytest
```

#### Using Conda (for data science)
```bash
# Create environment
conda create -n myproject python=3.11

# Activate environment
conda activate myproject

# Install packages
conda install numpy pandas matplotlib jupyter

# Install from pip if not available in conda
pip install fastapi

# Export environment
conda env export > environment.yml

# Create from environment file
conda env create -f environment.yml
```

### 2. Project Structure Template

Create a standard Python project structure:
```bash
mkdir -p ~/projects/myproject/{src,tests,docs,scripts,config}
cd ~/projects/myproject

# Create project structure
mkdir -p src/myproject
mkdir -p tests/unit tests/integration
mkdir -p docs
mkdir -p scripts
mkdir -p config

# Create essential files
touch src/myproject/__init__.py
touch tests/__init__.py
touch README.md
touch requirements.txt
touch .gitignore
touch .env.example
```

### 3. Essential Configuration Files

#### pyproject.toml (Poetry)
```toml
[tool.poetry]
name = "myproject"
version = "0.1.0"
description = "Description of your project"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
packages = [{include = "myproject", from = "src"}]

[tool.poetry.dependencies]
python = "^3.11"
requests = "^2.31.0"
fastapi = "^0.104.0"
uvicorn = "^0.24.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
black = "^23.0.0"
flake8 = "^6.1.0"
mypy = "^1.6.0"
pre-commit = "^3.5.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
addopts = "-v --tb=short"
```

#### requirements.txt (if not using Poetry)
```txt
# Production dependencies
fastapi==0.104.0
uvicorn[standard]==0.24.0
requests==2.31.0
pydantic==2.4.0
python-multipart==0.0.6

# Development dependencies (install with: pip install -r requirements-dev.txt)
```

#### requirements-dev.txt
```txt
-r requirements.txt

# Development tools
pytest==7.4.0
pytest-cov==4.1.0
black==23.0.0
flake8==6.1.0
mypy==1.6.0
pre-commit==3.5.0
bandit==1.7.5
safety==2.3.0

# Documentation
sphinx==7.2.0
sphinx-rtd-theme==1.3.0

# Jupyter for experimentation
jupyter==1.0.0
ipykernel==6.25.0
```

#### .gitignore
```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
venv/
env/
ENV/
.venv/
.env

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.cache
nosetests.xml
coverage.xml

# MyPy
.mypy_cache/
.dmypy.json
dmypy.json

# Jupyter
.ipynb_checkpoints

# Environment variables
.env
.env.local
.env.production

# Logs
*.log
logs/

# Database
*.db
*.sqlite

# Temporary files
tmp/
temp/
```

#### .env.example
```bash
# Application settings
DEBUG=True
SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://user:password@localhost/dbname

# API Keys
API_KEY=your-api-key-here
EXTERNAL_SERVICE_URL=https://api.example.com

# Development settings
LOG_LEVEL=DEBUG
ENVIRONMENT=development
```

## Development Tools Configuration

### 1. Pre-commit Hooks

Set up pre-commit hooks for code quality:
```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.9.1
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/PyCQA/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        additional_dependencies: [flake8-docstrings]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.6.1
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]
EOF

# Install hooks
pre-commit install

# Run on all files
pre-commit run --all-files
```

### 2. Testing Setup

#### Basic test structure
```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from myproject.main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def sample_data():
    return {
        "name": "Test User",
        "email": "test@example.com"
    }
```

#### Sample test file
```python
# tests/test_main.py
def test_root_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}

def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()
```

#### Run tests with coverage
```bash
# Install coverage
pip install pytest-cov

# Run tests with coverage
pytest --cov=src/myproject --cov-report=html --cov-report=term

# View coverage report
python -m http.server 8000 -d htmlcov/
```

### 3. Documentation Setup

#### Sphinx documentation
```bash
# Install sphinx
pip install sphinx sphinx-rtd-theme

# Initialize docs
mkdir docs
cd docs
sphinx-quickstart

# Build docs
make html

# Serve docs
cd _build/html
python -m http.server 8000
```

#### API documentation with FastAPI
```python
# src/myproject/main.py
from fastapi import FastAPI
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.openapi.utils import get_openapi

app = FastAPI(
    title="My Project API",
    description="A sample API built with FastAPI",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="My Project API",
        version="1.0.0",
        description="A sample API built with FastAPI",
        routes=app.routes,
    )
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi
```

## Database Setup

### 1. SQLite (for development)
```python
# requirements.txt
sqlalchemy==2.0.23
alembic==1.12.1

# src/myproject/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### 2. PostgreSQL (for production)
```bash
# Install PostgreSQL client
sudo apt install -y postgresql-client

# Install Python driver
pip install psycopg2-binary

# Or for async support
pip install asyncpg
```

```python
# For async PostgreSQL
SQLALCHEMY_DATABASE_URL = "postgresql+asyncpg://user:password@localhost/dbname"

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

engine = create_async_engine(SQLALCHEMY_DATABASE_URL)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)
```

### 3. Database Migrations with Alembic
```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Initial migration"

# Run migration
alembic upgrade head

# Downgrade
alembic downgrade -1
```

## Performance and Monitoring

### 1. Logging Configuration
```python
# src/myproject/logging_config.py
import logging
import sys
from logging.handlers import RotatingFileHandler

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            RotatingFileHandler(
                'app.log',
                maxBytes=10*1024*1024,  # 10MB
                backupCount=5
            )
        ]
    )
```

### 2. Environment-specific Configuration
```python
# src/myproject/config.py
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    app_name: str = "My Project"
    debug: bool = False
    database_url: str
    secret_key: str
    api_key: Optional[str] = None
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### 3. Health Checks
```python
# src/myproject/health.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .database import get_db

router = APIRouter()

@router.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        # Check database connection
        db.execute("SELECT 1")
        return {
            "status": "healthy",
            "database": "connected"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }
```

## Deployment Preparation

### 1. Docker Setup
```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "myproject.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myproject
    depends_on:
      - db
    volumes:
      - .:/app
    command: uvicorn myproject.main:app --host 0.0.0.0 --port 8000 --reload

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myproject
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

### 2. Production Configuration
```python
# src/myproject/config.py
import os
from typing import Any, Dict, Optional

class Settings:
    def __init__(self):
        self.environment = os.getenv("ENVIRONMENT", "development")
        self.debug = self.environment == "development"
        self.database_url = os.getenv("DATABASE_URL")
        self.secret_key = os.getenv("SECRET_KEY")
        
        # Production-specific settings
        if self.environment == "production":
            self.allowed_hosts = ["your-domain.com"]
            self.cors_origins = ["https://your-frontend.com"]
        else:
            self.allowed_hosts = ["*"]
            self.cors_origins = ["*"]

settings = Settings()
```

## Development Workflow Scripts

Create helpful scripts in the `scripts/` directory:

### 1. Development Setup Script
```bash
#!/bin/bash
# scripts/setup.sh

echo "Setting up development environment..."

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Set up database
alembic upgrade head

echo "Setup complete! Activate virtual environment with: source venv/bin/activate"
```

### 2. Run Development Server
```bash
#!/bin/bash
# scripts/dev.sh

source venv/bin/activate
uvicorn src.myproject.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Run Tests
```bash
#!/bin/bash
# scripts/test.sh

source venv/bin/activate
pytest --cov=src/myproject --cov-report=html --cov-report=term-missing
```

### 4. Code Quality Check
```bash
#!/bin/bash
# scripts/lint.sh

source venv/bin/activate

echo "Running Black..."
black src/ tests/

echo "Running Flake8..."
flake8 src/ tests/

echo "Running MyPy..."
mypy src/

echo "Running Bandit..."
bandit -r src/

echo "All checks complete!"
```

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

## Next Steps

1. **Choose your framework**: FastAPI, Django, Flask, etc.
2. **Set up your database**: PostgreSQL, MySQL, SQLite
3. **Configure CI/CD**: GitHub Actions, GitLab CI, etc.
4. **Deploy your application**: Docker, cloud platforms
5. **Monitor your application**: Logging, metrics, alerts

Your Python development environment is now ready for serious development work on your remote Ubuntu server!
