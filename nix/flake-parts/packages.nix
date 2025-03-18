{
  std,
  inputs,
  dream2nixModules,
}:
let
  inherit (inputs) dream2nix;
in
{
  perSystem =
    {
      system,
      pkgs,
      self',
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          ../overlay.nix
        ];
      };
      devShells =
        let
          mkDevShell =
            env:
            pkgs.mkShell {
              inherit (env) name;
              packages = [
                # python dev environment
                env
              ];
            };
        in
        {
          default = self'.packages.default.config.public.devShellNew;
          std = std.devShells.${system}.default;
        };
      packages = {
        default = dream2nix.lib.evalModules {
          packageSets.nixpkgs = inputs.nixpkgs.legacyPackages.${system};
          modules = [
            dream2nixModules.my-project
            {
              paths.projectRoot = ../..;
              paths.projectRootFile = "flake.nix";
              paths.package = "./my_project";
            }
          ];
        };
      };
    };
}
