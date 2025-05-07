# deploy-embedding
This repo is meant to deploy lightweighted embedding models as docker containers

Here the app is served using `make deploy` 

**Docker image**: to create & run it:

* docker build -t rag-app:0.0.1 .
* docker run -p 8501:8501 --env-file .env rag-app:0.0.1
* docker image tag rag-app:0.0.1 pdemeulenaer/rag-app:0.0.1
* docker login
* docker image push pdemeulenaer/rag-app:0.0.1
