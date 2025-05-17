{ ... }:
{
  projectRootFile = "flake.nix";

  # nix code
  programs.deadnix.enable = true;
  programs.nixfmt.enable = true;
}
