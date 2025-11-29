package main

import (
	"fmt"
	"os"

	dotfileslib "github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

func main() {
	if len(os.Args) < 2 {
		dotfileslib.ShowMainHelp()
		os.Exit(0)
	}

	command := os.Args[1]

	switch command {
	case "--help", "-h", "help":
		dotfileslib.ShowMainHelp()
	case "link":
		handleLink()
	case "unlink":
		handleUnlink()
	case "list":
		handleList()
	default:
		fmt.Fprintf(os.Stderr, "Error: unknown command '%s'\n", command)
		dotfileslib.ShowMainHelp()
		os.Exit(1)
	}
}

// handleLink はlinkサブコマンドを処理する
func handleLink() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		dotfileslib.ShowLinkHelp()
		return
	}

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

// handleUnlink はunlinkサブコマンドを処理する
func handleUnlink() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		dotfileslib.ShowUnlinkHelp()
		return
	}

	manager := dotfileslib.NewDotfilesManager()

	// 管理しているdotfilesのリンク削除
	manager.RemoveDotfileLinks()

	// .gitconfig.localの削除
	if err := manager.RemoveGitConfigLocal(); err != nil {
		os.Exit(1)
	}

	// vimデータディレクトリの削除
	if err := manager.RemoveVimDataDir(); err != nil {
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

// handleList はlistサブコマンドを処理する
func handleList() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		dotfileslib.ShowListHelp()
		return
	}

	manager := dotfileslib.NewDotfilesManager()
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
