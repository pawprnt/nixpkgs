{
  description = "pawprnt's custom nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsDir = ./pkgs;
      entries = builtins.readDir pkgsDir;
      packageNames = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      # check if a package needs python
      isPythonPackage = name:
        let
          content = builtins.readFile (pkgsDir + "/${name}/default.nix");
        in
        nixpkgs.lib.hasInfix "buildPythonPackage" content;

      mkOverlay = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        final: prev:
          let
            normalPkgs = builtins.filter (n: !(isPythonPackage n)) packageNames;
            pythonPkgs = builtins.filter isPythonPackage packageNames;
          in
          builtins.listToAttrs (map (name: {
            inherit name;
            value = pkgs.callPackage (pkgsDir + "/${name}") {};
          }) normalPkgs) //
          builtins.listToAttrs (map (name: {
            inherit name;
            value = pkgs.python3Packages.callPackage (pkgsDir + "/${name}") {};
          }) pythonPkgs);

      overlay = mkOverlay "x86_64-linux";
    in {
      packages = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        normalPkgs = builtins.filter (n: !(isPythonPackage n)) packageNames;
        pythonPkgs = builtins.filter isPythonPackage packageNames;
        allPkgs = builtins.listToAttrs (map (name: {
          inherit name;
          value = pkgs.callPackage (pkgsDir + "/${name}") {};
        }) normalPkgs) //
        builtins.listToAttrs (map (name: {
          inherit name;
          value = pkgs.python3Packages.callPackage (pkgsDir + "/${name}") {};
        }) pythonPkgs);
      in allPkgs // { default = allPkgs; });

      overlays.default = overlay;
    };
}
