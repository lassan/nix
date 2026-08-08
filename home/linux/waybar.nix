{pkgs, ...}: let
  theme = import ../theme.nix;
in {
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

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: alpha(${theme.background}, 0.75);
        color: ${theme.foreground};
      }

      #workspaces button {
        padding: 0 10px;
        color: ${theme.comment};
        background: transparent;
      }

      #workspaces button.active {
        color: ${theme.background};
        background: ${theme.accent};
        border-radius: 6px;
      }

      #workspaces button.urgent {
        color: ${theme.background};
        background: ${theme.orange};
        border-radius: 6px;
      }

      #window {
        color: ${theme.comment};
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

      #cpu { color: ${theme.green}; }
      #memory { color: ${theme.purple}; }
      #temperature { color: ${theme.yellow}; }
      #custom-gpu { color: ${theme.cyan}; }
      #pulseaudio { color: ${theme.orange}; }
      #network { color: ${theme.cyan}; }
      #clock { color: ${theme.foreground}; font-weight: bold; }

      #temperature.critical { color: ${theme.red}; }
    '';
  };

  home.packages = [pkgs.pavucontrol];
}
