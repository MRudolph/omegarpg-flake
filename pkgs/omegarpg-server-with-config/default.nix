{
  writeShellApplication,
  omegarpg
}:
writeShellApplication {
  name = "omega-rpg-server-with-config";

  runtimeInputs = [ omegarpg ];

  text = (builtins.readFile ./omege-rpg-server-with-config.sh);
}