{ config, pkgs, ... }:
{
  home.username = "sh1nome";
  home.homeDirectory = "/home/sh1nome";

  home.stateVersion = "24.05";

  # 設定のシンボリックリンク
  home.file = {
    ".bashrc".source = ./../.bashrc;
    ".vimrc".source = ./../.vimrc;
    ".gitconfig".source = ./../.gitconfig;
    ".config/nvim".source = ./../nvim;
  };

  # 必要なアプリのインストール
  home.packages = with pkgs; [
    vim
    neovim
    git
    bashInteractive
  ];

  programs.home-manager.enable = true;
}
