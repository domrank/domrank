.PHONY: down
down:
	@docker rm -f devcontainer-domrank >/dev/null 2>&1 || true
