{
  pkgs,
  lib,
  llib,
}:
{

  scope = {
    executablePackages = { ... }: with pkgs; [ coreutils ];
  };

}
