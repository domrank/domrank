DEV_IMAGE ?= ghcr.io/domrank/domrank-dev

.PHONY: up
up:
	@./hack/devspace-service.sh up

.PHONY: down
down:
	@./hack/devspace-service.sh down

.PHONY: status
status:
	@./hack/devspace-service.sh status

.PHONY: windows-ssh
windows-ssh:
	./hack/windows-ssh.sh

.PHONY: code
code: windows-ssh
	./hack/code.sh

.PHONY: ssh
ssh:
	ssh domrank.devspace

.PHONY: dev-image
dev-image:
	DEV_IMAGE=$(DEV_IMAGE) ./hack/dev-image.sh

.PHONY: run
run:
	go run .
