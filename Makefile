.ONESHELL:

SHELL := $(shell which bash)

# Image name
IMAGE_NAME := deploy-embeddings

# Read version from version.txt
VERSION := $(shell cat version.txt)


# 0. General local commands

env-file:
	cp .env.sample .env

# conda:
# 	conda env create --file environment.yml --yes
# 	$(CONDA_ACTIVATE) databricks-llm-fine-tuning-demo

install:
#	pip install -r requirements.txt
#	pip install -e .
	poetry install
	poetry lock

# pre-commit:
# 	pre-commit install

# setup: env-file conda pre-commit

black:
	black .

lint:
	mypy src
	pylint src

test:
	behave tests/features/

doc: 
	mkdocs build	

quality: black lint test

quality-ci: lint test


.PHONY: build run

build:
	@echo "Building image version: $(VERSION)"
	@docker build -t $(IMAGE_NAME):$(VERSION) .
	@echo "Built image: $(IMAGE_NAME):$(VERSION)"

run:
	@echo "Running image version: $(VERSION)"
	@docker run -d -p 8000:8000 --name $(IMAGE_NAME) $(IMAGE_NAME):$(VERSION)
	@echo "Running image: $(IMAGE_NAME):$(VERSION)"
	@echo "Access the app at http://localhost:8000"

# to run the fastapi app locally
serve:
	poetry run uvicorn deploy_embeddings.app:app --host 0.0.0.0 --port 8000 --reload

ingest:
	poetry run python -m src.app_rag_db.ingest_to_qdrant	

health:
	curl http://localhost:8000/health

test:
	curl -X POST http://localhost:8000/embed -H "Content-Type: application/json" -d '{"text": "This is a test sentence."}'
