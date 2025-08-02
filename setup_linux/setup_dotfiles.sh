#!/bin/sh

# dotfilesディレクトリの絶対パスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")/.."; pwd)"

# Gitユーザー名とメールアドレスを対話的に取得
read -p "Gitのユーザー名を入力してください: " git_user
read -p "Gitのメールアドレスを入力してください: " git_email

# .gitconfig.local を作成・更新
cat > "$DOTFILES_DIR/.gitconfig.local" <<EOF
[user]
        name = $git_user
        email = $git_email
EOF

# 各種設定ファイルのシンボリックリンクを作成
ln -sfn "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sfn "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sfn "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES_DIR/.gitconfig.local" "$HOME/.gitconfig.local"
mkdir -p "$HOME/.config/Code/User"
ln -sfn "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
ln -sfn "$DOTFILES_DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
ln -sfn "$DOTFILES_DIR/vscode/prompts" "$HOME/.config/Code/User/"

# 完了メッセージを表示
echo "シンボリックリンクを作成しました。"
echo "\n現在のdotfilesシンボリックリンク一覧:"
# findで取得したリンクを一時ファイルに保存
find ~ -type l -lname "*dotfiles*" -exec bash -c 'echo "$1 -> $(basename $(readlink -f "$1"))"' _ {} \; > /tmp/dotfiles_links_list
# 表示順リスト
links="\
.bashrc
.vimrc
.gitconfig
.gitconfig.local
settings.json
keybindings.json
prompts
"
# 順番に表示しつつ一時ファイルから削除
for link in $links; do
  grep " $link$" /tmp/dotfiles_links_list
  sed -i "/ $link$/d" /tmp/dotfiles_links_list
done
# 残りをまとめて表示
if [ -s /tmp/dotfiles_links_list ]; then
  echo "その他:"
  cat /tmp/dotfiles_links_list
fi
# 一時ファイル削除
rm -f /tmp/dotfiles_links_list
