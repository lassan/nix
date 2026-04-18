{...}: {
  programs = {
    television = {
      enable = true;
      enableZshIntegration = true;
      channels = {
        "tldr" = {
          metadata = {
            name = "tldr";
            description = "Browse tldr pages";
          };

          source = {
            command = "tldr --list";
          };

          preview = {
            command = "tldr '{}'";
          };

          keybindings = {
            "enter" = "actions:open";
          };

          actions = {
            "open" = {
              command = "tldr '{}'";
              mode = "execute";
            };
          };
        };
      };
    };

    nix-search-tv = {
      enable = true;
    };
  };
}
