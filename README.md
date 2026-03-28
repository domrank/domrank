# domrank

The initial web project for `domrank.org`.

The repository currently focuses on a local Dev Container workflow for development.

## Dev Container

Open the repository from the WSL/Linux filesystem and then reopen it in the container with the VS Code Dev Containers extension.

The container definition lives in `.devcontainer/devcontainer.json`. It uses the published `mcr.microsoft.com/devcontainers/go:1.25` image and adds the Node feature.

The container keeps the fixed Docker name `devcontainer-domrank`. During initialization, `initializeCommand` runs `make down` on the host so rebuilds always clear any existing container with that name before recreating it.

If you prefer the CLI instead of the VS Code command:

```bash
make up
```

To remove the current dev container manually from the host:

```bash
make down
```

## Structure

- `.devcontainer/devcontainer.json`: Dev Container configuration
- `Makefile`: local helpers for bringing the dev container up or down
- `.vscode/extensions.json`: recommended VS Code extensions inside the container
