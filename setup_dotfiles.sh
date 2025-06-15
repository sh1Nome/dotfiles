#!/bin/sh

# dotfilesディレクトリの絶対パスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"

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
ln -sfn "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sfn "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES_DIR/.gitconfig.local" "$HOME/.gitconfig.local"

# 完了メッセージを表示
echo "シンボリックリンクを作成しました。"
