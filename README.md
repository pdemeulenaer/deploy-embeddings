# deploy-embedding
This repo is meant to deploy lightweighted embedding models as docker containers

Here the app is served locally (for testing outside Docker) using `make serve` 

**Docker image**: to create & run it:

* make build
* make run (for testing the container locally)
* make tag (to tag the image to a DockerHub repository)
* docker login (to login to DockerHub)
* make push (will push the image to DockerHub)
  
<!-- * docker run -p 8501:8501 --env-file .env rag-app:0.0.1
* docker image tag rag-app:0.0.1 pdemeulenaer/rag-app:0.0.1
* docker login
* docker image push pdemeulenaer/rag-app:0.0.1 -->
