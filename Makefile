.ONESHELL:

SHELL := $(shell which bash)

# Image name
IMAGE_NAME := deploy-embeddings

# Read version from version.txt
VERSION := $(shell cat version.txt)
DOCKER_FOLDER := pdemeulenaer

.PHONY: build run tag push

# 0. General local commands
install:
	poetry install
	poetry lock


# 1. To run the fastapi app locally & test it
serve:
	poetry run uvicorn deploy_embeddings.app:app --host 0.0.0.0 --port 8000 --reload	

health:
	curl http://localhost:8000/health

test:
	curl -X POST http://localhost:8000/embed -H "Content-Type: application/json" -d '{"text": "This is a test sentence."}'

test_big:
	curl -X POST http://localhost:8000/embed -H "Content-Type: application/json" -d '{"text": "This is a test sentence that is really really long. Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet"}'


# 2. Docker commands
build:
	@echo "Building image version: $(VERSION)"
	@docker build -t $(IMAGE_NAME):$(VERSION) .
	@echo "Built image: $(IMAGE_NAME):$(VERSION)"

run:
	@echo "Running image version: $(VERSION)"
	@docker run -d -p 8000:8000 --name $(IMAGE_NAME) $(IMAGE_NAME):$(VERSION)
	@echo "Running image: $(IMAGE_NAME):$(VERSION)"
	@echo "Access the app at http://localhost:8000"

tag:
	@echo "Tag image version: $(VERSION)"
	@docker tag $(IMAGE_NAME):$(VERSION) $(DOCKER_FOLDER)/$(IMAGE_NAME):$(VERSION)
	@echo "Tagged image: $(DOCKER_FOLDER)/$(IMAGE_NAME):$(VERSION)"

push:
	@echo "Pushing image version: $(VERSION)"
	@docker push $(DOCKER_FOLDER)/$(IMAGE_NAME):$(VERSION)
	@echo "Pushed image: $(DOCKER_FOLDER)/$(IMAGE_NAME):$(VERSION)"		


# 3. To test the deployed fastapi app in Azure
test_azure:
	curl -X POST https://rag-gbdgccage7bkgwa8.northeurope-01.azurewebsites.net/embed -H "Content-Type: application/json" -d '{"text": "This is a test sentence."}'

test_azure_big:
	curl -X POST https://rag-gbdgccage7bkgwa8.northeurope-01.azurewebsites.net/embed -H "Content-Type: application/json" -d '{"text": "This is a test sentence that is really really long. Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed. Falling back to regular HTTP download. For better performance, install the package with: `pip install huggingface_hub[hf_xet]` or `pip install hf_xet"}'

