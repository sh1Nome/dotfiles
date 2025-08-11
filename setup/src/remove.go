package main

import (
	"fmt"
	"os"

	dotfileslib "github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

func main() {
	// DotfilesManagerの初期化
	manager := dotfileslib.NewDotfilesManager()

	// 管理しているdotfilesのリンク削除
	manager.RemoveDotfileLinks()

	// .gitconfig.localの削除
	if err := manager.RemoveGitConfigLocal(); err != nil {
		os.Exit(1)
	}

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを削除しました。")
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
