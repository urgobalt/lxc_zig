{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = with pkgs;
        mkShell {
          packages = [
            clang-tools
            zig
            zls
            lxc
          ];
          shellHook = ''
            export CC="zig cc"
            export LD_LIBRARY_PATH=${lxc}/lib:$LD_LIBRARY_PATH
          '';
        };
    });
}
