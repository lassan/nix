{...}: {
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };

      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };
    };
  };
}
