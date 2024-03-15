{
  system,
  pkgs,
  lockFile,
  fenix,
}: let
  cargoToml = builtins.fromTOML (builtins.readFile ../Cargo.toml);
  toolchain = fenix.packages.${system}.minimal.toolchain;
in
  (pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  })
  .buildRustPackage {
    pname = cargoToml.package.name;
    version = cargoToml.package.version;

    src = ../.;

    cargoLock = {
      lockFile = lockFile;
    };

    buildInputs = with pkgs; [
      libpulseaudio
    ];

    nativeBuildInputs = with pkgs; [
      pkg-config
      makeWrapper
      rustfmt
    ];

    doCheck = true;
    CARGO_BUILD_INCREMENTAL = "false";
    RUST_BACKTRACE = "full";
    copyLibs = true;

    postInstall = ''
      wrapProgram $out/bin/scope-tui
    '';

    meta = with pkgs.lib; {
      homepage = "https://github.com/linuxmobile/scope-tui";
      description = "A simple oscilloscope/vectorscope/spectroscope for your terminal";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "scope-tui";
    };
  }
