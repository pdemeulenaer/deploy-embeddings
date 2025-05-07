# ===========================
#  🚀 Stage 1: Builder
# ===========================
FROM python:3.11-slim AS builder

# Install system dependencies required by unstructured[all-docs]
RUN apt-get update && apt-get install -y \
    libmagic1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy dependency files first for caching
COPY pyproject.toml poetry.lock* ./

# Install dependencies inside a virtual environment
RUN poetry config virtualenvs.in-project true \
    && poetry install --no-interaction --no-ansi --no-root \
    && rm -rf /root/.cache/pip

# ===========================
#  📦 Stage 2: Final Image
# ===========================
FROM python:3.11-slim

# Install only required system dependencies
RUN apt-get update && apt-get install -y \
    libmagic1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy only the installed virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy the rest of the application code
COPY . .

# Set virtual environment path
ENV PATH="/app/.venv/bin:$PATH"

# Expose port for Streamlit
EXPOSE 8501

# Command to run the Streamlit app
CMD ["poetry", "run", "streamlit", "run", "src/app_rag_db/app.py", "--server.address=0.0.0.0"]
