# ===========================
#  🚧 Stage 1: Builder
# ===========================
FROM python:3.11-slim AS builder

# Environment settings
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry==2.1.2

# Copy pyproject and lock files
COPY pyproject.toml poetry.lock* /app/

# Use CPU-only PyTorch wheel index
RUN poetry config repositories.pytorch-cpu https://download.pytorch.org/whl/cpu
RUN poetry config installer.parallel false  # optional for deterministic builds

# Disable venv creation and install main dependencies only
RUN poetry config virtualenvs.create false && \
    poetry install --only main --no-root --no-interaction --no-ansi && \
    rm -rf /root/.cache

# # Preload model to cache it during build
# RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

# ===========================
#  📦 Stage 2: Final Runtime
# ===========================
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install runtime system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libsm6 libxrender1 libxext6 \
    && apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# Copy your app code
COPY src/deploy_embeddings/app.py /app/src/deploy_embeddings/

# Set PYTHONPATH to include src directory
ENV PYTHONPATH=/app/src

# Expose port
EXPOSE 8000

# Run FastAPI app via uvicorn
CMD ["uvicorn", "deploy_embeddings.app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--no-access-log"]





# FROM python:3.11-slim

# # Set working directory
# WORKDIR /app

# # System-level dependencies (build-essential & cleanup)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gcc \
#     && rm -rf /var/lib/apt/lists/*

# # Install Poetry
# RUN pip install --no-cache-dir poetry==2.1.2

# # Copy project metadata
# COPY pyproject.toml poetry.lock* ./

# # Configure Poetry (no venvs, only main deps)
# RUN poetry config virtualenvs.create false \
#     && poetry install --only main --no-root --no-interaction --no-ansi \
#     && rm -rf /root/.cache/pip

# # Install CPU-only PyTorch manually (overrides any version pulled via poetry)
# RUN pip install --no-cache-dir torch==2.7.0



# # Pre-download the model to cache it in the image
# RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

# # Copy application source code
# COPY src /app/src

# # Set Python path so imports work
# ENV PYTHONPATH=/app/src

# # Expose FastAPI port
# EXPOSE 8000

# # Start FastAPI app
# CMD ["uvicorn", "deploy_embeddings.app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--no-access-log"]
