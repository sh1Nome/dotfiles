package cmd

import (
	"fmt"
	"os"

	"github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

// Link はlinkサブコマンドを実行する
func Link() {
	manager := dotfileslib.NewDotfilesManager()

	// Windowsの場合はPowerShellの実行ポリシーを設定
	if err := manager.SetPowerShellExecutionPolicy(); err != nil {
		os.Exit(1)
	}

	// Gitユーザー名・メールアドレス取得と.gitconfig.local作成
	if err := manager.SetupGitConfigInteractive(); err != nil {
		os.Exit(1)
	}

	// 管理しているdotfilesのシンボリックリンク作成
	manager.CreateDotfileLinks()

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを作成しました。")
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
