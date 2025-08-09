package main

import (
	"fmt"
	"os"
	"path/filepath"

	dotfileslib "github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

func main() {
	// DotfilesManagerの初期化
	manager := dotfileslib.NewDotfilesManager()

	// Gitユーザー名・メールアドレス取得と.gitconfig.local作成
	if err := manager.SetupGitConfigInteractive(); err != nil {
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
