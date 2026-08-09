{
  config,
  pkgs,
  ...
}: {
  xdg.dataFile."vim/undo/.keep".text = "";

  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      vim-surround
      vim-commentary
      vim-repeat
      vim-sleuth
      vim-fugitive
      fzf-vim
    ];

    extraConfig = ''
      set number relativenumber
      set cursorline
      set showmatch
      set signcolumn=yes
      set scrolloff=5 sidescrolloff=5
      set splitbelow splitright
      set undofile
      set undodir=${config.xdg.dataHome}/vim/undo//
      set confirm wildmenu mouse=a
      set ignorecase smartcase incsearch hlsearch
      set clipboard=unnamed
      syntax enable
      filetype plugin indent on

      if has('termguicolors')
        set termguicolors
      endif

      let mapleader = ' '
      nnoremap <leader>f :Files<CR>
      nnoremap <leader>b :Buffers<CR>
      nnoremap <leader>g :Rg<Space>

      augroup readonly_quit
        autocmd!
        autocmd BufReadPost * if &readonly | nnoremap <silent><buffer> q :quit<CR> | endif
      augroup END
    '';
  };
}
