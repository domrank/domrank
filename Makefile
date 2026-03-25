.PHONY: up
up:
	devspace dev

.PHONY: down
down:
	devspace reset pods
	devspace purge
  