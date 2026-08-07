{
  config,
  inputs,
  pkgs,
  ...
}: let
  # Stable path, not the store path: zellij keys plugin permissions on the
  # location string, so a store path re-prompts on every update.
  radarPath = "${config.xdg.configHome}/zellij/plugins/zj_radar.wasm";
  scrollbackEditor = pkgs.writeShellScript "vim-scrollback" ''
    exec ${pkgs.vim}/bin/vim -R "$@"
  '';
in {
  xdg.configFile."zellij/plugins/zj_radar.wasm".source = "${inputs.zj-radar.packages.${pkgs.system}.default}/bin/zj_radar.wasm";

  # The sidebar itself is wired declaratively below; this is the
  # `zj-radar setup --check` doctor and the `zj-radar notify` producer shim.
  home.packages = [inputs.zj-radar.packages.${pkgs.system}.zj-radar-cli];

  programs.zellij = {
    enable = true;

    # Shell integration off: shell.nix does the auto-attach itself.

    # A custom `default` layout replaces zellij's built-in wholesale and
    # inherits nothing, so the status-bar pane and the swap layouts are restated
    # here verbatim from `zellij setup --dump-swap-layout default`. Without them
    # `Alt [` / `Alt ]` are silent no-ops; without `new_tab_template` zellij
    # exits instantly with "Bye from Zellij!" because the first tab resolves to
    # plugin panes with no terminal to host. `ui` must duplicate
    # `default_tab_template`, since swap layouts can only reference a named one.
    layouts.default = ''
      layout {
          default_tab_template {
              pane split_direction="vertical" {
                  pane size=32 borderless=false {
                      plugin location="radar"
                  }
                  children
              }
              pane size=1 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }
          new_tab_template {
              pane split_direction="vertical" {
                  pane size=32 borderless=false {
                      plugin location="radar"
                  }
                  pane focus=true
              }
              pane size=1 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }

          tab_template name="ui" {
              pane split_direction="vertical" {
                  pane size=32 borderless=false {
                      plugin location="radar"
                  }
                  children
              }
              pane size=1 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }

          swap_tiled_layout name="vertical" {
              ui max_panes=5 {
                  pane split_direction="vertical" {
                      pane
                      pane { children; }
                  }
              }
              ui max_panes=8 {
                  pane split_direction="vertical" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                  }
              }
              ui max_panes=12 {
                  pane split_direction="vertical" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                      pane { pane; pane; pane; pane; }
                  }
              }
          }

          swap_tiled_layout name="horizontal" {
              ui max_panes=4 {
                  pane
                  pane
              }
              ui max_panes=8 {
                  pane {
                      pane split_direction="vertical" { children; }
                      pane split_direction="vertical" { pane; pane; pane; pane; }
                  }
              }
              ui max_panes=12 {
                  pane {
                      pane split_direction="vertical" { children; }
                      pane split_direction="vertical" { pane; pane; pane; pane; }
                      pane split_direction="vertical" { pane; pane; pane; pane; }
                  }
              }
          }

          swap_tiled_layout name="stacked" {
              ui min_panes=5 {
                  pane split_direction="vertical" {
                      pane
                      pane stacked=true { children; }
                  }
              }
          }

          swap_floating_layout name="staggered" {
              floating_panes
          }

          swap_floating_layout name="enlarged" {
              floating_panes max_panes=10 {
                  pane { x "5%"; y 1; width "90%"; height "90%"; }
                  pane { x "5%"; y 2; width "90%"; height "90%"; }
                  pane { x "5%"; y 3; width "90%"; height "90%"; }
                  pane { x "5%"; y 4; width "90%"; height "90%"; }
                  pane { x "5%"; y 5; width "90%"; height "90%"; }
                  pane { x "5%"; y 6; width "90%"; height "90%"; }
                  pane { x "5%"; y 7; width "90%"; height "90%"; }
                  pane { x "5%"; y 8; width "90%"; height "90%"; }
                  pane { x "5%"; y 9; width "90%"; height "90%"; }
                  pane { x 10; y 10; width "90%"; height "90%"; }
              }
          }

          swap_floating_layout name="spread" {
              floating_panes max_panes=1 {
                  pane {y "50%"; x "50%"; }
              }
              floating_panes max_panes=2 {
                  pane { x "1%"; y "25%"; width "45%"; }
                  pane { x "50%"; y "25%"; width "45%"; }
              }
              floating_panes max_panes=3 {
                  pane { y "55%"; width "45%"; height "45%"; }
                  pane { x "1%"; y "1%"; width "45%"; }
                  pane { x "50%"; y "1%"; width "45%"; }
              }
              floating_panes max_panes=4 {
                  pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                  pane { x "50%"; y "55%"; width "45%"; height "45%"; }
                  pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                  pane { x "50%"; y "1%"; width "45%"; height "45%"; }
              }
          }
      }
    '';

    extraConfig = ''

          esc_delay 25

          // Aliased rather than pathed in the layout so this config block
          // applies everywhere the plugin is launched.
          plugins {
              radar location="file:${radarPath}" {
                  naming "managed"
                  glyphs "nerd"
                  header false
              }
          }

          theme "onedark"
          scrollback_editor "${scrollbackEditor}"

          keybinds clear-defaults=true {
          normal {
              bind "Ctrl l" { }
          }
          locked {
              bind "Ctrl g" { SwitchToMode "normal"; }
          }
          pane {
              bind "left" {}
              bind "down" {}
              bind "up" {}
              bind "right" {}
              bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
              bind "d" { NewPane "down"; SwitchToMode "normal"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
              bind "h" { MoveFocus "left"; }
              bind "i" { TogglePanePinned; SwitchToMode "normal"; }
              bind "j" { MoveFocus "down"; }
              bind "k" { MoveFocus "up"; }
              bind "l" { MoveFocus "right"; }
              bind "n" { NewPane; SwitchToMode "normal"; }
              bind "p" { SwitchFocus; }
              bind "Ctrl p" { SwitchToMode "normal"; }
              bind "r" { NewPane "right"; SwitchToMode "normal"; }
              bind "s" { NewPane "stacked"; SwitchToMode "normal"; }
              bind "w" { ToggleFloatingPanes; SwitchToMode "normal"; }
              bind "z" { TogglePaneFrames; SwitchToMode "normal"; }
          }
          tab {
              bind "left" {}
              bind "down" {}
              bind "up" {}
              bind "right" {}
              bind "1" { GoToTab 1; SwitchToMode "normal"; }
              bind "2" { GoToTab 2; SwitchToMode "normal"; }
              bind "3" { GoToTab 3; SwitchToMode "normal"; }
              bind "4" { GoToTab 4; SwitchToMode "normal"; }
              bind "5" { GoToTab 5; SwitchToMode "normal"; }
              bind "6" { GoToTab 6; SwitchToMode "normal"; }
              bind "7" { GoToTab 7; SwitchToMode "normal"; }
              bind "8" { GoToTab 8; SwitchToMode "normal"; }
              bind "9" { GoToTab 9; SwitchToMode "normal"; }
              bind "[" { BreakPaneLeft; SwitchToMode "normal"; }
              bind "]" { BreakPaneRight; SwitchToMode "normal"; }
              bind "b" { BreakPane; SwitchToMode "normal"; }
              bind "h" { GoToPreviousTab; }
              bind "j" { GoToNextTab; }
              bind "k" { GoToPreviousTab; }
              bind "l" { GoToNextTab; }
              bind "n" { NewTab; SwitchToMode "normal"; }
              bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
              bind "s" { ToggleActiveSyncTab; SwitchToMode "normal"; }
              bind "Ctrl t" { SwitchToMode "normal"; }
              bind "x" { CloseTab; SwitchToMode "normal"; }
              bind "tab" { ToggleTab; }
          }
          resize {
              bind "left" {}
              bind "down" {}
              bind "up" {}
              bind "right" {}
              bind "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "=" { Resize "Increase"; }
              bind "H" { Resize "Decrease left"; }
              bind "J" { Resize "Decrease down"; }
              bind "K" { Resize "Decrease up"; }
              bind "L" { Resize "Decrease right"; }
              bind "h" { Resize "Increase left"; }
              bind "j" { Resize "Increase down"; }
              bind "k" { Resize "Increase up"; }
              bind "l" { Resize "Increase right"; }
              bind "Ctrl n" { SwitchToMode "normal"; }
          }
          move {
              bind "left" {}
              bind "down" {}
              bind "up" {}
              bind "right" {}
              bind "h" { MovePane "left"; }
              bind "Ctrl h" { SwitchToMode "normal"; }
              bind "j" { MovePane "down"; }
              bind "k" { MovePane "up"; }
              bind "l" { MovePane "right"; }
              bind "n" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "tab" { MovePane; }
          }
          scroll {
              bind "e" { EditScrollback; SwitchToMode "normal"; }
              bind "s" { SwitchToMode "entersearch"; SearchInput 0; }
              bind "Ctrl s" { SwitchToMode "normal"; }
          }
          search {
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "n" { Search "down"; }
              bind "o" { SearchToggleOption "WholeWord"; }
              bind "p" { Search "up"; }
              bind "w" { SearchToggleOption "Wrap"; }
          }
          session {
              bind "a" {
                  LaunchOrFocusPlugin "zellij:about" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "Ctrl o" { SwitchToMode "normal"; }
              bind "p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "s" {
                  LaunchOrFocusPlugin "zellij:share" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
          }
          shared {
              bind "Alt down" { }
              bind "Alt up" { }
              bind "Alt +" { Resize "Increase"; }
              bind "Alt -" { Resize "Decrease"; }
              bind "Alt =" { Resize "Increase"; }
              bind "Alt [" { PreviousSwapLayout; }
              bind "Alt ]" { NextSwapLayout; }
              bind "Alt Shift f" { ToggleFloatingPanes;}
              bind "Alt h" { MoveFocusOrTab "left"; }
              bind "Alt i" { MoveTab "left"; }
              bind "Alt j" { MoveFocus "down"; }
              bind "Alt k" { MoveFocus "up"; }
              bind "Alt l" { MoveFocusOrTab "right"; }
              bind "Alt n" { NewPane; }
              bind "Alt o" { MoveTab "right"; }
          }
          shared_except "locked" {
              bind "Ctrl g" { SwitchToMode "locked"; }
              // The other half of killing the `git status` habit: gitui (421
              // invocations) as a keypress rather than a command.
              //
              // A Run pane inherits the *current* cwd of the focused pane —
              // including after a `cd`, verified against a real pty — so this
              // opens on the repo you are looking at, which is what makes it
              // usable across worktrunk worktrees.
              //
              // close_on_exit means `q` in gitui leaves nothing behind, so
              // repeated presses can't stack up floating panes. The tradeoff:
              // outside a git repo gitui exits immediately with an error and
              // the pane just flashes. Reads as "nothing happened", which is
              // the honest outcome anyway.
              bind "Alt g" {
                  Run "gitui" {
                      floating true
                      name "git"
                      close_on_exit true
                      x "5%"
                      y "5%"
                      width "90%"
                      height "90%"
                  }
              }
              bind "Alt a" {
                  MessagePlugin "radar" { name "zj_radar.cmd.v1"; payload "attention-next"; }
              }
              bind "Alt Shift a" {
                  MessagePlugin "radar" { name "zj_radar.cmd.v1"; payload "attention-prev"; }
              }
              bind "Alt p" { TogglePaneInGroup; }
              bind "Alt Shift p" { ToggleGroupMarking; }
              bind "Ctrl q" { Quit; }
          }
          shared_except "locked" "move" {
              bind "Ctrl h" { SwitchToMode "move"; }
          }
          shared_except "locked" "session" {
              bind "Ctrl o" { SwitchToMode "session"; }
          }
          shared_except "locked" "scroll" {
              bind "Ctrl s" { SwitchToMode "scroll"; }
          }
          shared_except "locked" "scroll" "search" "tmux" {
              bind "Ctrl b" { SwitchToMode "tmux"; }
          }
          shared_except "locked" "tab" {
              bind "Ctrl t" { SwitchToMode "tab"; }
          }
          shared_except "locked" "pane" {
              bind "Ctrl p" { SwitchToMode "pane"; }
          }
          shared_except "locked" "resize" {
              bind "Ctrl n" { SwitchToMode "resize"; }
          }
          shared_except "normal" "locked" "entersearch" {
              bind "enter" { SwitchToMode "normal"; }
          }
          shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
              bind "esc" { SwitchToMode "normal"; }
          }
          shared_among "pane" "tmux" {
              bind "x" { CloseFocus; SwitchToMode "normal"; }
          }
          shared_among "scroll" "search" {
              bind "PageDown" { PageScrollDown; }
              bind "PageUp" { PageScrollUp; }
              bind "left" {}
              bind "down" {}
              bind "up" {}
              bind "right" {}
              bind "Ctrl b" { PageScrollUp; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }
              bind "d" { HalfPageScrollDown; }
              bind "Ctrl f" { PageScrollDown; }
              bind "h" { PageScrollUp; }
              bind "j" { ScrollDown; }
              bind "k" { ScrollUp; }
              bind "l" { PageScrollDown; }
              bind "u" { HalfPageScrollUp; }
          }
          entersearch {
              bind "Ctrl c" { SwitchToMode "scroll"; }
              bind "esc" { SwitchToMode "scroll"; }
              bind "enter" { SwitchToMode "search"; }
          }
          renametab {
              bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
          }
          shared_among "renametab" "renamepane" {
              bind "Ctrl c" { SwitchToMode "normal"; }
          }
          renamepane {
              bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
          }
          shared_among "session" "tmux" {
              bind "d" { Detach; }
          }
          tmux {
              bind "left" { MoveFocus "left"; SwitchToMode "normal"; }
              bind "down" { MoveFocus "down"; SwitchToMode "normal"; }
              bind "up" { MoveFocus "up"; SwitchToMode "normal"; }
              bind "right" { MoveFocus "right"; SwitchToMode "normal"; }
              bind "space" { NextSwapLayout; }
              bind "\"" { NewPane "down"; SwitchToMode "normal"; }
              bind "%" { NewPane "right"; SwitchToMode "normal"; }
              bind "," { SwitchToMode "renametab"; }
              bind "[" { SwitchToMode "scroll"; }
              bind "Ctrl b" { Write 2; SwitchToMode "normal"; }
              bind "c" { NewTab; SwitchToMode "normal"; }
              bind "h" { MoveFocus "left"; SwitchToMode "normal"; }
              bind "j" { MoveFocus "down"; SwitchToMode "normal"; }
              bind "k" { MoveFocus "up"; SwitchToMode "normal"; }
              bind "l" { MoveFocus "right"; SwitchToMode "normal"; }
              bind "n" { GoToNextTab; SwitchToMode "normal"; }
              bind "o" { FocusNextPane; }
              bind "p" { GoToPreviousTab; SwitchToMode "normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }
          }
      }
    '';
  };
}
