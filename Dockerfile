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
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry==2.1.2

# Add PyTorch CPU-only index and optimize Poetry config
RUN poetry config installer.parallel false && \
    poetry config virtualenvs.create false

# Copy pyproject and lock file
COPY pyproject.toml poetry.lock* /app/

# Install project dependencies (main only, no dev)
RUN poetry install --only main --no-root --no-interaction --no-ansi && \
    rm -rf /root/.cache /root/.cache/pip ~/.cache

# 🔥 REMOVE unused files to slim the image
RUN find /usr/local/lib/python3.11/site-packages -type d -name '__pycache__' -exec rm -rf {} + && \
    find /usr/local/lib/python3.11/site-packages -type d -name 'tests' -exec rm -rf {} + && \
    find /usr/local -type f -name '*.pyc' -delete && \
    find /usr/local -type f -name '*.pyo' -delete && \
    find /usr/local -type f -name '*.so' -exec strip --strip-unneeded {} + || true    

# # Preload model to cache it during build if needed
# # RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"
# RUN python -c "from transformers import AutoTokenizer, AutoModel; AutoTokenizer.from_pretrained('sentence-transformers/all-MiniLM-L6-v2'); AutoModel.from_pretrained('sentence-transformers/all-MiniLM-L6-v2')"

# ===========================
#  📦 Stage 2: Final Runtime
# ===========================
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install runtime system packages # NOT ON DISTROLESS!!
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libsm6 libxrender1 libxext6 \
    && apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn
# COPY --from=builder /root/.cache/huggingface /root/.cache/huggingface # if need to have model cached in the image

# Copy your app code
# COPY src/deploy_embeddings/app.py /app/src/deploy_embeddings/
COPY src /app/src


# Set PYTHONPATH to include src directory
ENV PYTHONPATH=/app/src

# Expose FastAPI port
EXPOSE 8000

# Run FastAPI app via uvicorn
CMD ["sh", "-c", "uvicorn deploy_embeddings.app:app --host 0.0.0.0 --port ${PORT:-8000} --workers 1 --no-access-log"]