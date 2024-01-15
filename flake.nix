{
  description = "Manage development containers with Incus";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pname = "blincus";
        wrapScript = name: pkgs.writeShellScriptBin name (builtins.readFile ./${name});
        generateRunnablePackage = { name, dependencies }:
          pkgs.symlinkJoin {
            name = "${name}";
            paths = if dependencies != null then [(wrapScript name)] ++ dependencies else [(wrapScript name)];
            buildInputs = [pkgs.makeWrapper];
            postBuild = if name == pname then "wrapProgram $out/bin/${name} --prefix PATH : $out/bin" else "wrapProgram $out/bin/${name} --prefix PATH : $out/bin/${pname}-${name}";
          };
      in {
        packages = {
          default = self.packages.${system}.blincus;
          ${pname} = generateRunnablePackage { 
            name = "${pname}";
            dependencies = (with pkgs; [incus packer jq xorg.xhost coreutils gnugrep gnused getent util-linux dconf coreutils-full]);
          };
          install = generateRunnablePackage {
            name = "install";
            dependencies = (with pkgs; [curl wget gnutar coreutils]);
          };
          uninstall = generateRunnablePackage { 
            name = "uninstall"; 
            dependencies = with pkgs; [coreutils];
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [shellcheck nodePackages.bash-language-server];
        };

        formatter = pkgs.alejandra;
      }
    );
}
