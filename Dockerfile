# ===========================
#  🚀 Stage 1: Builder
# ===========================
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry==2.1.2

# Copy dependency files first for caching
COPY pyproject.toml poetry.lock* /app/

# # Install dependencies inside a virtual environment
# RUN poetry config virtualenvs.in-project true \
#     && poetry install --no-interaction --no-ansi --no-root \
#     && rm -rf /root/.cache/pip

# Install dependencies without dev dependencies
RUN poetry config virtualenvs.create false && \
poetry install --only main --no-root --no-interaction --no-ansi

# ===========================
#  📦 Stage 2: Final Image
# ===========================
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# # Copy only the installed virtual environment from builder
# COPY --from=builder /app/.venv /app/.venv

# # Copy the rest of the application code
# COPY . .
# Copy application code
COPY src/deploy_embeddings/app.py /app/src/deploy_embeddings/

# # Set virtual environment path
# ENV PATH="/app/.venv/bin:$PATH"

# Expose port
EXPOSE 8000

# Command to run the Streamlit app
CMD ["uvicorn", "deploy_embeddings.app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--no-access-log"]
