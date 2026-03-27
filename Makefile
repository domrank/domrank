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

.PHONY: check-windows-ssh
check-windows-ssh:
	./hack/sync-devspace-ssh-to-windows.sh check

.PHONY: sync-windows-ssh
sync-windows-ssh: check-windows-ssh
	./hack/sync-devspace-ssh-to-windows.sh

.PHONY: code
code: sync-windows-ssh
	code --folder-uri vscode-remote://ssh-remote+domrank.devspace/go/src/domrank

.PHONY: ssh
ssh:
	ssh domrank.devspace

.PHONY: dev-image
dev-image:
	docker build -f Dockerfile.dev -t $(DEV_IMAGE):latest .
	docker push $(DEV_IMAGE):latest

.PHONY: run
run:
	go run .
