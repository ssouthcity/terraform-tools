{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};  
    in
    {
      packages.default = pkgs.writeShellApplication {
        name = "terraform-update-git-refs";
        text = ''
          directory="$(pwd)"
          module="*"

          while getopts "d:m:" opt; do
            case "$opt" in
              d) directory="$OPTARG" ;;
              m) module="$OPTARG" ;;
              \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
            esac
          done

          shift $((OPTIND - 1))

          if [ $# -lt 1 ]; then
            echo "Please supply new ref"
            exit 1
          fi

          ref="$1"

          find "$directory" -type f -name "*.tf" | while read -r file; do
            sed -E -i "s|source = \"([^\"]*/?$module\?ref=)([^\"]*)\"|source = \"\1$ref\"|" "$file"
          done
        '';
      };
    }
  );
}
