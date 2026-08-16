{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
in {
  # glow has no stylix target and its built-in styles are fixed, so the palette
  # is written out as a glamour style JSON that fzf.nix and yazi.nix pass to -s.
  xdg.configFile."glow/stylix.json".source =
    (pkgs.formats.json {}).generate "glow-stylix.json"
    (with colors.withHashtag; {
      document = {
        block_prefix = "\n";
        block_suffix = "\n";
        color = base05;
        margin = 2;
      };
      block_quote = {
        color = base03;
        indent = 1;
        indent_token = "│ ";
      };
      list.level_indent = 2;
      heading = {
        block_suffix = "\n";
        color = base0D;
        bold = true;
      };
      h1 = {
        prefix = " ";
        suffix = " ";
        color = base00;
        background_color = base0D;
        bold = true;
      };
      h2.prefix = "## ";
      h3 = {
        prefix = "### ";
        color = base0C;
      };
      h4 = {
        prefix = "#### ";
        color = base0E;
      };
      h5 = {
        prefix = "##### ";
        color = base0A;
      };
      h6 = {
        prefix = "###### ";
        color = base09;
      };
      strikethrough.crossed_out = true;
      emph = {
        color = base09;
        italic = true;
      };
      strong = {
        color = base0A;
        bold = true;
      };
      hr = {
        color = base03;
        format = "\n--------\n";
      };
      item.block_prefix = "• ";
      enumeration.block_prefix = ". ";
      task = {
        ticked = "[✓] ";
        unticked = "[ ] ";
      };
      link = {
        color = base0C;
        underline = true;
      };
      link_text = {
        color = base0D;
        bold = true;
      };
      image = {
        color = base0C;
        underline = true;
      };
      image_text = {
        color = base03;
        format = "Image: {{.text}} →";
      };
      code = {
        prefix = " ";
        suffix = " ";
        color = base0B;
        background_color = base01;
      };
      code_block = {
        margin = 2;
        chroma = {
          text.color = base05;
          error.color = base08;
          comment.color = base03;
          comment_preproc.color = base0D;
          keyword.color = base0E;
          keyword_reserved.color = base0E;
          keyword_namespace.color = base08;
          keyword_type.color = base0A;
          operator.color = base0C;
          punctuation.color = base05;
          name.color = base05;
          name_builtin.color = base08;
          name_tag.color = base0E;
          name_attribute.color = base0D;
          name_class.color = base0A;
          name_constant.color = base09;
          name_decorator.color = base0D;
          name_exception.color = base08;
          name_function.color = base0D;
          literal.color = base09;
          literal_number.color = base09;
          literal_string.color = base0B;
          literal_string_escape.color = base0C;
          generic_deleted.color = base08;
          generic_emph.italic = true;
          generic_inserted.color = base0B;
          generic_strong.bold = true;
          generic_subheading.color = base0E;
          background.background_color = base00;
        };
      };
      table = {
        center_separator = "┼";
        column_separator = "│";
        row_separator = "─";
      };
      definition_description.block_prefix = "\n🠶 ";
    });
}
