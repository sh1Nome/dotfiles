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

	// シンボリックリンクの作成
	for _, l := range links {
		_ = os.Remove(l.Dst)
		// リンク先ディレクトリが存在しない場合は作成
		dstDir := filepath.Dir(l.Dst)
		if _, err := os.Stat(dstDir); os.IsNotExist(err) {
			if err := os.MkdirAll(dstDir, 0755); err != nil {
				fmt.Fprintf(os.Stderr, "ディレクトリ作成失敗: %s: %v\n", dstDir, err)
				continue
			}
		}
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
