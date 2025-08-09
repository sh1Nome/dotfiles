package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	dotfileslib "github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

func main() {
	// DotfilesManagerの初期化
	manager := dotfileslib.NewDotfilesManager()

	// Gitユーザー名とメールアドレスを対話的に取得
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Gitのユーザー名を入力してください: ")
	gitUser, _ := reader.ReadString('\n')
	gitUser = strings.TrimSpace(gitUser)
	fmt.Print("Gitのメールアドレスを入力してください: ")
	gitEmail, _ := reader.ReadString('\n')
	gitEmail = strings.TrimSpace(gitEmail)

	// .gitconfig.local を作成・更新
	gitconfigLocalPath := filepath.Join(manager.DotfilesDir, ".gitconfig.local")
	gitconfigLocalContent := fmt.Sprintf("[user]\n    name = %s\n    email = %s\n", gitUser, gitEmail)
	if err := os.WriteFile(gitconfigLocalPath, []byte(gitconfigLocalContent), 0644); err != nil {
		fmt.Fprintf(os.Stderr, ".gitconfig.localの作成に失敗: %v\n", err)
		os.Exit(1)
	}

	// 管理しているdotfilesリストを取得
	links := manager.ManagedDotfiles()
	// .gitconfig.localのsrcだけは生成したパスに差し替え
	for i, l := range links {
		if filepath.Base(l.Dst) == ".gitconfig.local" {
			links[i].Src = gitconfigLocalPath
		}
	}

	// 必要なディレクトリの作成
	_ = os.MkdirAll(filepath.Join(manager.Home, ".config/Code/User"), 0755)

	// シンボリックリンクの作成
	for _, l := range links {
		_ = os.Remove(l.Dst)
		if err := os.Symlink(l.Src, l.Dst); err != nil {
			fmt.Fprintf(os.Stderr, "リンク作成失敗: %s -> %s: %v\n", l.Src, l.Dst, err)
		}
	}

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを作成しました。")
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
