{ config, pkgs, lib, ... }: let
  bstar = pkgs.requireFile {
    name = "bstar-0.5.10.so";
    sha256 = "0wp4l2phfdbdzjz60zrphpkmg360cd9sanqvr9bhckg41yyw0cfs";
    message = ''
      download bstar-0.5.10.so and add it to nix store:
      nix-prefetch-url --type sha256 --name bstar-0.5.10.so file:///path/to/bstar-0.5.10.so
    '';
  };
in {
  options.chronocat.bstar = lib.mkOption {
    type = lib.types.path;
    description = "bstar";
  };
  config.chronocat.bstar = let
    qq = pkgs.qq.overrideAttrs { meta = {}; };
  in pkgs.stdenv.mkDerivation {
    name = "bstar";
    buildInputs = with pkgs; [ stdenv.cc.cc.lib ];
    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    unpackPhase = ":";
    installPhase = ''
      mkdir -p $out/{lib,bin}
      # preventing removal by gc
      ln -s ${bstar} $out/.bstar
      cp ${bstar} $out/lib/bstar.so
      cat > $out/bin/bstar <<EOF
      #!${pkgs.runtimeShell}
      LD_PRELOAD=$out/lib/bstar.so BQQNT_CC=1 exec ${qq}/bin/qq \$@
      EOF
      chmod +x $out/lib/bstar.so $out/bin/bstar
    '';
  };
}
