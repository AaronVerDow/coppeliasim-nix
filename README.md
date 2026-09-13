# CoppeliaSim Nix

Nix flake to run CoppeliaSim

This uses `steam-run` to create the appropriate environment, and adds in some additional libraries.

Download the Ubuntu 24.04 version to repo root, extract it, then run:

```
nix develop
./start.sh
```

Alternatively, enable `direnv` for to load the dev environment automatically.

There are still some warnings, but so far this is working.
