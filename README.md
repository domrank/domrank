# domrank

The initial web project for `domrank.org`.

For now, the application itself stays as a simple `Hello World` Go server so we can focus on the DevSpace and image workflow.

## Run

```bash
make run
```

The default port is `9000`. In deployment environments, you can override it with the `PORT` environment variable.

## DevSpace

`make up` uses a prebuilt development image.

`domrank-dev` is a shared development base image. `make dev-image` is responsible for building and pushing it, and DevSpace only consumes it via `devImage`.

Run the following only the first time, or whenever the dev image needs to be rebuilt:

```bash
make dev-image
```

This command runs `docker build` with `Dockerfile.dev` and pushes `ghcr.io/domrank/domrank-dev:latest`.
Before running it, make sure `docker login ghcr.io` is already configured.

After that, `make up` can quickly reuse the `Go + Node + pnpm` environment.

If you are using WSL with Windows VS Code, start DevSpace first:

```bash
make up
```

Then open VS Code from another terminal:

```bash
make code
```

`make code` syncs the DevSpace SSH entry and key material to the Windows-side SSH config just before launching VS Code. You can also use it later to reopen VS Code without restarting DevSpace.

To run only the SSH sync step:

```bash
make sync-windows-ssh
```

To verify SSH connectivity (and print remote hostname) without copying anything:

```bash
make check-windows-ssh
```

## Structure

- `main.go`: simple `Hello World` web server
- `Dockerfile.dev`: development image with `Go + Node + pnpm`
- `devspace.yaml`: DevSpace configuration and dev image pipeline
