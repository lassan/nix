{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      character = {
        success_symbol = "[I›](bold green)";
        error_symbol = "[I›](bold red)";
        vimcmd_symbol = "[N›](bold green)";
        vimcmd_replace_symbol = "[C›](bold purple)";
        vimcmd_visual_symbol = "[V›](bold yellow)";
      };

      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };

      git_metrics = {
        disabled = false;
      };
    };
  };
}
