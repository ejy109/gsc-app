AZURESSHPRVKEYFILE ?= ~/cvm_key.pem
AZURESSHIP ?= 127.0.0.1

APPNAME := app
APPVERSION := 0.2

APPIMAGETAGNAME := $(APPNAME):$(APPVERSION)
GSCAPPIMAGETAGNAME := gsc-$(APPNAME):$(APPVERSION)

GSC_GITURL := https://github.com/gramineproject/gsc.git
GSC_GITCOMMIT := 24430f8

.PHONY: all gsc-app docker-app test-app deploy clean

all: gsc-app

setup-gsc:
	rm -rf gsc
	git clone $(GSC_GITURL) && cd gsc && git checkout $(GSC_GITCOMMIT)
	cp config.yaml gsc/

gsc-app: setup-gsc docker-app
	cp gramine.manifest gsc/
	cd gsc; \
	openssl genrsa -3 -out gramine-enclave-key.pem 3072 && \
	./gsc build --no-cache --rm $(APPIMAGETAGNAME) gramine.manifest && \
	./gsc sign-image $(APPIMAGETAGNAME) gramine-enclave-key.pem

docker-app:
	cd app; \
	cat Dockerfile | docker build \
		-t $(APPIMAGETAGNAME) \
		--progress=plain \
		-f - .

test-app:
	$(info [NOTICE] It is expected to fail as lack of device files needed.)
	docker run --rm $(APPIMAGETAGNAME) || [ $$? -eq 255 ]

test-gsc-app:
	docker run --rm --device=/dev/sgx_enclave --device=/dev/sgx/enclave -v /var/run/aesmd/aesm.socket:/var/run/aesmd/aesm.socket $(GSCAPPIMAGETAGNAME)

deploy:
	@echo "AZURE ssh private key file: $(AZURESSHPRVKEYFILE)"
	@echo "AZURE ssh ip address: $(AZURESSHIP)"
	@docker save $(GSCAPPIMAGETAGNAME) | bzip2 | pv | ssh -i $(AZURESSHPRVKEYFILE) azureuser@$(AZURESSHIP) docker load

clean:
	rm -rf gsc
