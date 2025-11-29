package main

import (
	"fmt"
	"os"

	"github.com/sh1Nome/dotfiles/setup/ui/common"
	"github.com/sh1Nome/dotfiles/setup/usecase"
)

func main() {
	if len(os.Args) < 2 {
		common.ShowMainHelp()
		os.Exit(0)
	}

	command := os.Args[1]

	switch command {
	case "--help", "-h", "help":
		common.ShowMainHelp()
	case "link":
		handleLink()
	case "unlink":
		handleUnlink()
	case "list":
		handleList()
	default:
		fmt.Fprintf(os.Stderr, "Error: unknown command '%s'\n", command)
		common.ShowMainHelp()
		os.Exit(1)
	}
}

// handleLink はlinkサブコマンドを処理する
func handleLink() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		common.ShowLinkHelp()
		return
	}
	if err := usecase.ExecuteLink(); err != nil {
		os.Exit(1)
	}
	common.PromptForEnter()
}

// handleUnlink はunlinkサブコマンドを処理する
func handleUnlink() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		common.ShowUnlinkHelp()
		return
	}
	if err := usecase.ExecuteUnlink(); err != nil {
		os.Exit(1)
	}
	common.PromptForEnter()
}

// handleList はlistサブコマンドを処理する
func handleList() {
	// 引数が2個以上あり、かつ2番目の引数がヘルプオプション（--help または -h）かどうか判定
	if len(os.Args) > 2 && (os.Args[2] == "--help" || os.Args[2] == "-h") {
		common.ShowListHelp()
		return
	}
	if err := usecase.ExecuteList(); err != nil {
		os.Exit(1)
	}
	common.PromptForEnter()
}

