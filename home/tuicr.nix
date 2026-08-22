{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
in {
  # tuicr has no stylix target, so the oxocarbon palette is hand-mapped into
  # its local-theme schema and referenced by name from config.toml.
  xdg.configFile."tuicr/config.toml".source = (pkgs.formats.toml {}).generate "tuicr-config.toml" {
    theme = "oxocarbon";
    diff_view = "side-by-side";
    appearance = "dark";
  };

  xdg.configFile."tuicr/themes/oxocarbon.toml".source =
    (pkgs.formats.toml {}).generate "tuicr-oxocarbon.toml"
    (with colors.withHashtag; {
      panel_bg = base00;
      bg_highlight = base02;
      fg_primary = base05;
      fg_secondary = base04;
      fg_dim = base03;

      diff_add = base0B;
      diff_add_bg = base01;
      diff_del = base08;
      diff_del_bg = base01;
      diff_context = base05;
      diff_hunk_header = base0D;
      expanded_context_fg = base03;

      syntax_add_bg = base01;
      syntax_del_bg = base01;

      file_added = base0B;
      file_modified = base0A;
      file_deleted = base08;
      file_renamed = base0E;

      reviewed = base0B;
      pending = base0A;

      comment_note = base0D;
      comment_suggestion = base0C;
      comment_issue = base08;
      comment_praise = base0B;

      border_focused = base0D;
      border_unfocused = base02;
      status_bar_bg = base01;
      cursor_color = base0A;
      cursor_line_bg = base01;
      branch_name = base0E;
      help_indicator = base04;

      message_info_fg = base00;
      message_info_bg = base0D;
      message_warning_fg = base00;
      message_warning_bg = base0A;
      message_error_fg = base00;
      message_error_bg = base08;
      update_badge_fg = base00;
      update_badge_bg = base0A;

      mode_fg = base00;
      mode_bg = base0D;
    });
}
