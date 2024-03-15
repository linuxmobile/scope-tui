self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.types) bool package int str;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;

  boolToString = x:
    if x
    then "true"
    else "false";
  cfg = config.programs.scope-tui;
  filterOptions = options:
    builtins.filter (opt: builtins.elemAt opt 1 != "") options;
in {
  options.programs.scope-tui = {
    enable =
      mkEnableOption ""
      // {
        description = ''
          I really love cava. It provides a crude but pleasant frequency plot for your music: just the bare minimum to see leads solos and basslines. I wanted to also be able to see waveforms, but to my knowledge nothing is available. There is some soundcard oscilloscope software available, but the graphical GUI is usually dated and breaks the magic. I thus decided to solve this very critical issue with my own hands! And over a night of tinkering with pulseaudio (via libpulse-simple-binding) and some TUI graphics (via tui-rs), the first version of scope-tui was developed, with very minimal settings given from command line, but a bonus vectorscope mode baked in.
        '';
      };

    package = mkOption {
      description = "A simple oscilloscope/vectorscope/spectroscope for your terminal";
      type = package;
      default = self.package.${pkgs.stdenv.hostPlatform.system}.scope-tui;
    };
    channels = mkOption {
      description = "number of channels to open [default: 2]";
      type = int;
      default = 2;
    };
    tune = mkOption {
      description = "tune buffer size to be in tune with given note (overrides buffer option)";
      type = str;
    };
    buffer = mkOption {
      description = "size of audio buffer, and width of scope [default: 8192]";
      type = int;
      default = 8192;
    };
    sample-rate = mkOption {
      description = "sample rate to use [default: 44100]";
      type = int;
      default = 44100;
    };
    range = mkOption {
      description = "sample rate to use [default: 44100]";
      type = int;
      default = 44100;
    };
    scatter = mkOption {
      description = "use vintage looking scatter mode instead of line mode";
      type = bool;
    };
    no-reference = mkOption {
      description = "don't draw reference line";
      type = bool;
    };
    no-ui = mkOption {
      description = "hide UI and only draw waveforms";
      type = bool;
    };
    no-braille = mkOption {
      description = "don't use braille dots for drawing lines";
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    xdg.configFile."scope-tui/config.toml".text = let
      formatOption = name: value: "${name}=${value}";
      formatConfig = options:
        builtins.concatStringsSep "\n" (map (opt:
          formatOption (builtins.head opt)
          (builtins.elemAt opt 1))
        options);
    in ''
      ${formatConfig (filterOptions [
        [
          ["channels" (toString cfg.channels)]
          ["buffer" (toString cfg.buffer)]
          ["sample-rate" (toString cfg.sample-rate)]
          ["range" (toString cfg.range)]
        ]
      ])}
    '';
  };
}
