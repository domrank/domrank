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

`domrank-dev` is a shared development base image. `make dev-image` runs `hack/dev-image.sh`, which stages the newest local `.vscode-server/extensions` directory for each recommendation in `.vscode/extensions.json`, then builds and pushes the image. DevSpace only consumes it via `devImage`.

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

`make code` syncs the DevSpace SSH entry and key material to the Windows-side SSH config, verifies SSH connectivity, and then launches VS Code. You can also use it later to reopen VS Code without restarting DevSpace.

To sync Windows-side SSH config and then verify SSH connectivity:

```bash
make windows-ssh
```

## Structure

- `main.go`: simple `Hello World` web server
- `Dockerfile.dev`: development image with `Go + Node + pnpm`
- `devspace.yaml`: DevSpace configuration and dev image pipeline
