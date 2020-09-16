let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09-alpha.tar.gz";
    sha256 = "0dxrfr0w5ksvpjwz0d2hy7x7dirnc2xk9nw1np3wr6kvdlzhs3ik";
  }) { };
  jechol = import (fetchTarball {
    url = "https://github.com/jechol/nur-packages/archive/v2.0.tar.gz";
    sha256 = "00ii854c5srffq7zn5bi9m1gdyvqcxjs1pryw32ybcl2daw3d0k5";
  }) { };
in nixpkgs.mkShell {
  buildInputs = [
    jechol.beam.main.erlangs.erlang_22_0
    jechol.beam.main.packages.erlang_22_0.elixirs.elixir_1_10_0
    nixpkgs.nodejs-14_x
    nixpkgs.ruby_2_7
    nixpkgs.rubyPackages_2_7.rubocop
    nixpkgs.rubyPackages_2_7.pry
    nixpkgs.python39
  ];
}
