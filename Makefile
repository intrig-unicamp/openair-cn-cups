# imagem para rodar os binários
IMAGE_NAME=openair-cn-cups

# tag da imagem
IMAGE_TAG=latest

# diretório do projeto específico que contém o CMakeLists.txt
PROJECT_DIR=$(CURDIR)

# diretório de trabalho no container
WORK_CONTAINER_DIR=$(PROJECT_DIR)

# diretório de testes
TEST_DIR=$(PROJECT_DIR)/build/Debug

NUM_THREADS=8

.PHONY: help

help:
	@echo "Usage: make [comando]"
	@echo "Gerencia o container de build."
	@echo
	@echo "Comandos:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "- \033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Função para realizar diversos tipos de build locais
# O primeiro parâmetro é o tipo do build
define build
	docker run -it --workdir $(WORK_CONTAINER_DIR) -v $(PROJECT_DIR):$(PROJECT_DIR)  \
	$(IMAGE_NAME):$(IMAGE_TAG) /bin/bash -c \
	'cd $(PROJECT_DIR)/build/scripts && \
	./build_spgwu -c -V -b Debug -j'
endef


debug: ## Build in Debug mode
	docker-build
	$(call build)


clean: ## Clean generated artifects
	docker run -it -v  $(PROJECT_DIR):$(PROJECT_DIR)   \
	$(IMAGE_CROSS) /bin/bash -c \
	'cd $(PROJECT_DIR)/build/Debug && make clean && \
	cd $(PROJECT_DIR)/build/Release && make clean'

shell-run: ## Login in docker bash mode
	docker run -it --workdir $(WORK_CONTAINER_DIR) -v $(PROJECT_DIR):$(PROJECT_DIR)   \
	$(IMAGE_NAME) /bin/bash
    
docker-create-network: ## Create macvlan with subnet 192.168.15.0 using enp0s20f0u1 interface
	docker network create -d macvlan --subnet=192.168.15.0/24 --gateway=192.168.15.1 -o parent=enp0s20f0u1 macvlan-enp0s20f0u1

docker-connect-network: ## Connect maclan on container openair-cn-cups
	docker network connect macvlan-enp0s20f0u1 openair-cn-cups

docker-run: ## Login in docker bash mode
	docker run -it --workdir $(WORK_CONTAINER_DIR) -v $(PROJECT_DIR):$(PROJECT_DIR)   \
	$(IMAGE_NAME) /bin/bash -c './build/spgw_u/build/spgwu -c ./etc/spgw_u-dev.conf'
 
docker-build: ## Build docker image
	docker build --build-arg UID=$$(id -u) --build-arg GID=$$(id -g) -t $(IMAGE_NAME) docker/.

    
