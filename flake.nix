{
  description = "Custom packages for dealing with common Terraform operations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      treefmt = forEachSupportedSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forEachSupportedSystem (pkgs: treefmt.${pkgs.system}.config.build.wrapper);

      checks = forEachSupportedSystem (pkgs: {
        formatting = treefmt.${pkgs.system}.config.build.check self;
      });

      packages = forEachSupportedSystem (pkgs: {
        default = pkgs.symlinkJoin {
          name = "terraform-tools";
          paths = [
            self.packages.${pkgs.system}.terraform-refplace
          ];
        };

        terraform-refplace = pkgs.callPackage ./pkgs/terraform-refplace.nix { };
      });
    };
}
