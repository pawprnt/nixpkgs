# pawprnt/nixpkgs

custom nix packages as a nixos overlay.

## packages

| package | description |
|---------|-------------|
| [forager](pkgs/forager) | steam-like game launcher for your local library |
| [softie](pkgs/softie) | kawaii self-care desktop companion |
| [prowl](pkgs/prowl) | security research cli tool |

## usage

### as a nixos overlay (recommended)

add this repo as a flake input:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  pawprnt-pkgs = {
    url = "github:pawprnt/nixpkgs";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

apply the overlay in your nixos configuration:

```nix
nixpkgs.overlays = [ inputs.pawprnt-pkgs.overlays.default ];
```

then install packages like any other:

```nix
environment.systemPackages = [
  pkgs.forager
  pkgs.softie
  pkgs.prowl
];
```

or run them directly:

```bash
nix run github:pawprnt/nixpkgs#forager
nix run github:pawprnt/nixpkgs#softie
nix run github:pawprnt/nixpkgs#prowl
```

### as a flake (without overlay)

you can also access packages directly:

```nix
nix run github:pawprnt/nixpkgs#forager
```

## adding a package

1. create a directory under `pkgs/<name>/`
2. add a `default.nix` with the package expression
3. the flake auto-discovers packages from the `pkgs/` directory

### package template

```nix
{ lib
, buildGoModule  # or buildPythonPackage, stdenv, etc.
, fetchFromGitHub
}:

buildGoModule {
  pname = "my-package";
  version = "1.0.0";
  vendorHash = null;

  src = fetchFromGitHub {
    owner = "my-owner";
    repo = "my-repo";
    rev = "v1.0.0";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  meta = with lib; {
    description = "My awesome package";
    homepage = "https://github.com/my-owner/my-repo";
    license = licenses.mit;
    mainProgram = "my-package";
  };
}
```

## CI

packages are automatically published via the `nix-publish` reusable workflow. when a new version tag is pushed to a package repo, the workflow:

1. checks out this repo
2. computes the source hash
3. updates the `default.nix` with the correct hash
4. commits and pushes

to trigger manually, call the workflow with a version tag.
