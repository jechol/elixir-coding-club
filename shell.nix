let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09-alpha.tar.gz";
    sha256 = "0dxrfr0w5ksvpjwz0d2hy7x7dirnc2xk9nw1np3wr6kvdlzhs3ik";
  }) { };
  jechol = import (fetchTarball {
    url = "https://github.com/jechol/nix-beam/archive/v3.0.tar.gz";
    sha256 = "17z11hxc9z9ph0p5im9wd635g2ha9fm9k8vkz7rjpcqzsj3iwz7m";
  }) { };
in nixpkgs.mkShell {
  buildInputs = [
    jechol.beam.main.erlangs.erlang_23_1
    jechol.beam.main.packages.erlang_23_1.elixirs.elixir_1_11_0
  ];
}
