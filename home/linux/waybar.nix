{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 12;

      modules-left = ["hyprland/workspaces" "hyprland/submap"];
      modules-center = ["hyprland/window"];
      modules-right = [
        "cpu"
        "temperature"
        "custom/gpu"
        "memory"
        "pulseaudio"
        "network"
        "clock"
        "tray"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 90;
        separate-outputs = true;
      };

      cpu.format = "󰻠 {usage}%";
      memory.format = "󰍛 {percentage}%";

      temperature = {
        critical-threshold = 85;
        format = " {temperatureC}°C";
      };

      # waybar has no nvidia module; nvidia-smi ships with the driver.
      "custom/gpu" = {
        exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader";
        format = "󰢮 {}°C";
        interval = 10;
        tooltip = false;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons.default = ["󰕿" "󰖀" "󰕾"];
        on-click = "pavucontrol";
      };

      network = {
        format-wifi = "󰖩 {essid}";
        format-ethernet = "󰈀 wired";
        format-disconnected = "󰖪 offline";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%a %d %b %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      tray.spacing = 10;
    };

    # @baseXX are declared by the stylix waybar target, which prepends them to
    # this block.
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: alpha(@base00, 0.75);
        color: @base05;
      }

      #workspaces button {
        padding: 0 10px;
        color: @base03;
        background: transparent;
      }

      #workspaces button.active {
        color: @base00;
        background: @base0D;
        border-radius: 6px;
      }

      #workspaces button.urgent {
        color: @base00;
        background: @base09;
        border-radius: 6px;
      }

      #window {
        color: @base03;
      }

      #cpu,
      #memory,
      #temperature,
      #custom-gpu,
      #pulseaudio,
      #network,
      #clock,
      #tray {
        padding: 0 10px;
      }

      #cpu { color: @base0B; }
      #memory { color: @base0E; }
      #temperature { color: @base0A; }
      #custom-gpu { color: @base0C; }
      #pulseaudio { color: @base09; }
      #network { color: @base0D; }
      #clock { color: @base05; font-weight: bold; }

      #temperature.critical { color: @base08; }
    '';
  };

  home.packages = [pkgs.pavucontrol];
}
