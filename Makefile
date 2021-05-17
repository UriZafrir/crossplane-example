# Copyright (c) Datalayer, Inc https://datalayer.io
# Distributed under the terms of the MIT License.

CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
CONDA_DEACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda deactivate
CONDA_REMOVE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda remove -y --all -n

.PHONY: clean build dist env

.EXPORT_ALL_VARIABLES:

VERSION = 0.0.1

default: all ## Default target is all.

help: ## display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all: clean install build dist ## Clean, install and build.

clean:
	rm -fr build
	rm -fr dist
	rm -fr *.egg-info
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '__pycache__' -exec rm -fr {} +

env:
	-conda env create -f environment.yml 
	@echo
	@echo -----------------------------------------------
	@echo ✨  Crossplane Examples Environment is installed
	@echo -----------------------------------------------
	@echo

install:
	($(CONDA_ACTIVATE) crossplane-examples; \
		python setup.py install && \
		yarn install )

dev:
	($(CONDA_ACTIVATE) crossplane-examples; \
		pip install -e . && \
		yarn install )

build:
	($(CONDA_ACTIVATE) crossplane-examples; \
		python setup.py sdist bdist_egg bdist_wheel && \
		yarn build )

publish:
	($(CONDA_ACTIVATE) crossplane-examples; \
		python setup.py sdist bdist_egg bdist_wheel upload )

repl:
	($(CONDA_ACTIVATE) crossplane-examples; \
		PYTHONPATH=./dist/crossplane_examples-${VERSION}-py3-none-any.whl python )

start:
	echo open http://localhost:8765
	echo open http://localhost:8765/api/crossplane
	($(CONDA_ACTIVATE) crossplane-examples; \
		yarn start )

# --progress=tty
# --no-cache
docker-build: ## build the image.
	docker build \
	  -t localhost:5000/crossplane-examples:${VERSION} \
	  -f Dockerfile \
	  .

docker-push: ## push the image.
	docker push \
	  localhost:5000/crossplane-examples:${VERSION}

docker-tag: ## push the image.
	docker tag \
	  localhost:5000/crossplane-examples:${VERSION} \
	  datalayer/crossplane-examples:${VERSION}

docker-push-datalayer: docker-tag ## push the image.
	docker push \
	  datalayer/crossplane-examples:${VERSION}

docker-start: ## start the container.
	echo open http://localhost:8765
	echo open http://localhost:8765/api/crossplane
	docker run \
	  -it \
	  -d \
	  --rm \
	  --env-file ./.env \
	  --name crossplane-examples \
	  -p 8765:8765 \
	  localhost:5000/crossplane-examples:${VERSION}

docker-connect: ## connect to the container.
	docker exec -it crossplane-examples bash

docker-logs: ## show container logs.
	docker logs crossplane-examples -f

docker-stop: ## stop the container.
	docker stop crossplane-examples

docker-rm: ## remove the container.
	docker rm -f crossplane-examples

helm-update: ## update helm.
	helm repo add datalayer s3://datalayer-helm/charts
	helm repo update

helm-install: ## install helm.
	helm upgrade \
		--install crossplane-examples \
		datalayer/crossplane-examples \
		--version ${VERSION} \
		--create-namespace \
		--namespace crossplane-examples
	make helm-status

helm-deploy: ## deploy helm.
	helm upgrade \
		--install crossplane-examples \
		./etc/helm-chart \
		--create-namespace \
		--namespace crossplane-examples
	make helm-status

helm-status: ## helm status - !!! Does not work in this env.
	echo open http://localhost:30000
	helm ls -n crossplane-examples
	kubectl get all -n crossplane-examples

helm-rm: # helm delete
	helm delete crossplane-examples --namespace crossplane-examples

helm-build: # helm build.
	helm package ./etc/helm-chart
	ls crossplane-examples-${VERSION}.tgz
	mv crossplane-examples-${VERSION}.tgz helm-charts
	helm repo index helm-charts --url http://datalayer-helm.s3.amazonaws.com/charts

helm-clean: # helm clean.
	rm crossplane-examples-${VERSION}.tgz

helm-push: # helm push.
	aws s3 cp \
		helm-charts \
		s3://datalayer-helm/charts \
		--recursive \
		--profile datalayer

port-forward: # port forward.
	echo open http://localhost:20000
	kubectl port-forward service/crossplane-examples-service 20000:80 -n crossplane-examples

crossplane-apply: # crossplane deploy.
	kubectl apply -f ./etc/managed

crossplane-status: # crossplane status.
	kubectl get managed

platform-xrd-instal: # install platform ref.
	kubectl apply -f ./etc/platform-ref-gcp/network
	kubectl apply -f ./etc/platform-ref-gcp/cluster/services
	kubectl apply -f ./etc/platform-ref-gcp/cluster/gke
	kubectl apply -f ./etc/platform-ref-gcp/cluster

platform-deploy: # deploy platform ref.
	kubectl apply -f ./etc/platform-ref-gcp/examples

kubeconfig: # get kubeconfig
	echo $(kubectl get secret cluster-conn -n default -o jsonpath='{.data.kubeconfig}') | base64 --decode > kubeconfig
	cat kubeconfig
