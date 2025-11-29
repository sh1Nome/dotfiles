package cmd

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

// List はlistサブコマンドを実行する
func List() {
	manager := dotfileslib.NewDotfilesManager()
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
