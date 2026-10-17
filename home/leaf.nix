{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
in {
  home.packages = [(pkgs.callPackage ../packages/leaf.nix {})];

  xdg.configFile."leaf/config.toml".source = (pkgs.formats.toml {}).generate "leaf-config.toml" {
    theme = "stylix";
  };

  # leaf has no stylix target. Syntax highlighting is limited to syntect's
  # bundled themes, so code blocks keep base16-ocean rather than the palette.
  xdg.configFile."leaf/themes/stylix.toml".source =
    (pkgs.formats.toml {}).generate "leaf-stylix.toml"
    (with colors.withHashtag; {
      base = "ocean";
      syntax = "base16-ocean.dark";
      ui = {
        toc_bg = base00;
        toc_border = base02;
        content_bg = base00;
        scrollbar_hover = base0A;
        status_bg = base01;
        status_separator = base03;
        status_brand_fg = base00;
        status_brand_bg = base0D;
        status_filename_fg = base05;
        status_filename_bg = base02;
        status_watch_fg = base0B;
        status_watch_bg = base01;
        status_reloaded_fg = base00;
        status_reloaded_bg = base0B;
        status_search_fg = base0A;
        status_search_bg = base02;
        status_success_fg = base0B;
        status_success_bg = base01;
        status_warning_fg = base0A;
        status_error_fg = base08;
        status_error_bg = base01;
        status_shortcut_fg = base04;
        status_percent_fg = base0A;
        status_dot_fg = base03;
        toc_hover_fg = base07;
        toc_header_fg = base04;
        toc_active_bg = base02;
        toc_inactive_bg = base00;
        toc_accent = base09;
        toc_index_inactive = base03;
        toc_primary_active = base07;
        toc_primary_inactive = base05;
        toc_secondary_inactive = base03;
        toc_secondary_text_active = base06;
        toc_secondary_text_inactive = base04;
      };
      markdown = {
        search_highlight_bg = base02;
        search_match_bg = base0A;
        code_gutter = base03;
        blockquote_marker = base03;
        list_level_1 = base0B;
        list_level_2 = base0D;
        list_level_3 = base0E;
        ordered_list = base0A;
        table_border = base03;
        table_separator = base02;
        table_header = base0A;
        table_cell = base05;
        heading_1 = base0D;
        heading_2 = base0C;
        heading_3 = base0E;
        heading_4 = base0A;
        heading_other = base09;
        heading_underline = base02;
        code_frame = base03;
        code_label = base04;
        inline_code_fg = base0B;
        inline_code_bg = base01;
        rule = base02;
        link_icon = base0C;
        link_text = base0C;
        link_hover = base0D;
        blockquote_text = base04;
        text = base05;
        strong_text = base07;
        latex_inline_fg = base0E;
        latex_inline_bg = base01;
        latex_block_fg = base0E;
        mermaid_keyword = base09;
        mermaid_arrow = base0D;
        mermaid_label = base0B;
        mermaid_block_fg = base05;
        mark_fg = base00;
        mark_bg = base0A;
        task_checked = base0B;
        task_unchecked = base03;
        alert_note = base0D;
        alert_tip = base0B;
        alert_important = base0E;
        alert_warning = base0A;
        alert_caution = base08;
        footnote_ref = base0D;
        footnote_text = base04;
      };
      diff = {
        file_separator_fg = base05;
        tree_tag_change = base09;
        tree_tag_renamed = base0D;
      };
    });
}
