{
  config,
  dream2nix,
  lib,
  packageSets,
  ...
}:
let
  src = config.paths.projectRoot;
in
{
  imports = [ dream2nix.modules.dream2nix.WIP-python-pdm ];
  pdm.lockfile = src + /pdm.lock;
  pdm.pyproject = src + /pyproject.toml;
  mkDerivation = {
    inherit src;
    buildInputs = [ config.deps.python.pkgs.pdm-backend ];
  };
  buildPythonPackage.catchConflicts = false;
  deps =
    { nixpkgs, ... }:
    {
      python = nixpkgs.python312;
    };
  public = {
    # devShell = config.deps.mkShell;
    devShellNew = config.public.devShell.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [
        packageSets.nixpkgs.pdm
        # config.deps.python.pkgs.virtualenv
        # (config.deps.python.pkgs.virtualenvwrapper.override (_: {
        #   virtualenv-clone = config.deps.python.pkgs.virtualenv-clone.overridePythonAttrs (_: {
        #     doCheck = false;
        #   });
        # }))
      ];
    });
    env = config.deps.python.withPackages (
      ps: config.mkDerivation.propagatedBuildInputs
    );
  };
}
