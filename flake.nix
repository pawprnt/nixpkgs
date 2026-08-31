{
  description = "pawprnt's custom nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      callPackage = pkgs.callPackage;

      # auto-discover packages from pkgs/ directory
      pkgsDir = ./pkgs;
      entries = builtins.readDir pkgsDir;
      packageNames = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      packages = builtins.listToAttrs (map (name: {
        inherit name;
        value = callPackage (pkgsDir + "/${name}") {};
      }) packageNames);
    in {
      packages.${system} = packages // { default = packages; };
    };
}
