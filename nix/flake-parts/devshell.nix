{ std, ... }:
{
  perSystem =
    {
      system,
      pkgs,
      ...
    }:
    {
      devShells = {
        std = std.devShells.${system}.default;
      };
    };
}
