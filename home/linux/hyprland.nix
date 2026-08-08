{
  lib,
  pkgs,
  ...
}: let
  theme = import ../theme.nix;

  inherit (lib.generators) mkLuaInline;

  bind = keys: dispatcher: {_args = [keys (mkLuaInline dispatcher)];};

  workspaceBinds = builtins.concatMap (index: let
    key =
      if index == 10
      then "0"
      else toString index;
  in [
    (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${toString index} })")
    (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString index}, follow = true })")
  ]) (lib.range 1 10);

  directionBinds = lib.mapAttrsToList (key: direction:
    bind "SUPER + ${key}" "hl.dsp.focus({ direction = \"${direction}\" })") {
    h = "l";
    j = "d";
    k = "u";
    l = "r";
  };

  moveBinds = lib.mapAttrsToList (key: direction:
    bind "SUPER + SHIFT + ${key}" "hl.dsp.window.swap({ direction = \"${direction}\" })") {
    h = "l";
    j = "d";
    k = "u";
    l = "r";
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;

    # home-manager still defaults this to hyprlang at stateVersion 25.11, which
    # writes a hyprland.conf that Hyprland 0.55+ does not read.
    configType = "lua";

    # Hyprland and the portal come from programs.hyprland in modules/nixos;
    # installing them again here would mix two versions.
    package = null;
    portalPackage = null;

    # uwsm owns the session units.
    systemd.enable = false;

    settings = {
      env = [
        {_args = ["LIBVA_DRIVER_NAME" "nvidia"];}
        {_args = ["__GLX_VENDOR_LIBRARY_NAME" "nvidia"];}
      ];

      monitor = [
        {
          output = "DP-1";
          mode = "3840x1600@74.98";
          position = "0x0";
          scale = 1;
        }
      ];

      # The Defy's firmware layout is US; the global gb below is for the other
      # keyboards. Hyprland resolves binds against the global keymap regardless,
      # so this only affects typed symbols.
      device = [
        {
          name = "dygma-defy-keyboard";
          kb_layout = "us";
        }
      ];

      config = {
        general = {
          border_size = 2;
          gaps_in = 6;
          gaps_out = 12;
          layout = "dwindle";
          resize_on_border = true;
          # A gradient is a table; a bare "colour colour 45deg" string is the
          # hyprlang form and is rejected as an invalid color.
          "col.active_border" = {
            colors = [
              (theme.alpha theme.accent "ee")
              (theme.alpha theme.accentAlt "ee")
            ];
            angle = 45;
          };
          "col.inactive_border" = theme.alpha theme.backgroundAlt "aa";
        };

        decoration = {
          rounding = 10;
          rounding_power = 4.0;
          active_opacity = 1.0;
          inactive_opacity = 0.94;

          blur = {
            enabled = true;
            size = 6;
            passes = 3;
            xray = true;
            popups = true;
            vibrancy = 0.2;
          };

          shadow = {
            enabled = true;
            range = 24;
            render_power = 3;
            color = theme.alpha theme.backgroundAlt "aa";
          };
        };

        animations.enabled = true;

        input = {
          kb_layout = "gb";
          follow_mouse = 1;
          sensitivity = 0;
          repeat_rate = 40;
          repeat_delay = 400;
        };

        dwindle = {
          preserve_split = true;

          # Upstream recommends this on widescreens, where W > H persists even
          # after several splits. This monitor is 3840x1600.
          split_width_multiplier = 1.35;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = true;
        };
      };

      curve = [
        {
          _args = [
            "snappy"
            {
              type = "bezier";
              points = [[0.05 0.9] [0.1 1.0]];
            }
          ];
        }
        {
          _args = [
            "overshoot"
            {
              type = "bezier";
              points = [[0.3 1.3] [0.4 1.0]];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4;
          bezier = "overshoot";
          style = "popin 80%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "snappy";
          style = "popin 80%";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 4;
          bezier = "snappy";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3;
          bezier = "snappy";
          style = "fade";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3;
          bezier = "snappy";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "snappy";
          style = "slide";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 8;
          bezier = "snappy";
        }
      ];

      bind =
        [
          (bind "SUPER + Return" "hl.dsp.exec_cmd(\"ghostty\")")
          (bind "SUPER + space" "hl.dsp.exec_cmd(\"vicinae toggle\")")
          (bind "SUPER + Q" "hl.dsp.window.close()")
          (bind "SUPER + V" "hl.dsp.window.float({ action = \"toggle\" })")
          (bind "SUPER + P" "hl.dsp.window.pseudo({ action = \"toggle\" })")
          (bind "SUPER + F" "hl.dsp.window.fullscreen({ action = \"toggle\" })")
          (bind "SUPER + M" "hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\" })")
          (bind "SUPER + C" "hl.dsp.window.center()")
          (bind "SUPER + B" "hl.dsp.exec_cmd(\"firefox\")")
          (bind "SUPER + E" "hl.dsp.exec_cmd(\"yazi\")")
          (bind "SUPER + L" "hl.dsp.exec_cmd(\"hyprlock\")")

          # uwsm owns the session, so tearing Hyprland down directly would strand
          # its units; stop the session instead.
          (bind "SUPER + SHIFT + E" "hl.dsp.exec_cmd(\"uwsm stop\")")

          (bind "SUPER + S" "hl.dsp.workspace.toggle_special(\"scratch\")")
          (bind "SUPER + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:scratch\" })")

          (bind "SUPER + mouse_down" "hl.dsp.focus({ workspace = \"e+1\" })")
          (bind "SUPER + mouse_up" "hl.dsp.focus({ workspace = \"e-1\" })")
          (bind "SUPER + mouse:272" "hl.dsp.window.drag()")
          (bind "SUPER + mouse:273" "hl.dsp.window.resize()")

          (bind "Print" "hl.dsp.exec_cmd(\"grim -g \\\"$(slurp)\\\" - | wl-copy\")")
          (bind "SHIFT + Print" "hl.dsp.exec_cmd(\"grim - | wl-copy\")")

          (bind "XF86AudioRaiseVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\")")
          (bind "XF86AudioLowerVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
          (bind "XF86AudioMute" "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
          (bind "XF86AudioPlay" "hl.dsp.exec_cmd(\"playerctl play-pause\")")
          (bind "XF86AudioNext" "hl.dsp.exec_cmd(\"playerctl next\")")
          (bind "XF86AudioPrev" "hl.dsp.exec_cmd(\"playerctl previous\")")
        ]
        ++ directionBinds
        ++ moveBinds
        ++ workspaceBinds;

      window_rule = [
        # Stacking rather than tiling: everything floats, drag with SUPER+LMB,
        # resize with SUPER+RMB or by grabbing a border. This makes the dwindle
        # settings above inert unless a window is un-floated with SUPER+V.
        {
          match = {class = ".*";};
          float = true;
          center = true;
        }
        {
          match = {title = "^(Picture-in-Picture)$";};
          pin = true;
        }
      ];
    };
  };

  home.packages = [pkgs.hyprpicker];
}
