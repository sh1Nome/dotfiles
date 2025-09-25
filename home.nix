{ config, pkgs, ... }:
{
  home.username = "root";
  home.homeDirectory = "/root";

  home.stateVersion = "24.05";

  # 設定のシンボリックリンク
  home.file = {
    ".bashrc".source = ./.bashrc;
    ".vimrc".source = ./.vimrc;
    ".gitconfig".source = ./.gitconfig;
  };

  # 必要なアプリのインストール
  home.packages = with pkgs; [
    vim
    git
    bashInteractive
  ];

  programs.home-manager.enable = true;
}
