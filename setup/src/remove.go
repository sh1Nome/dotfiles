package main

import (
	"fmt"
	"os"
	dotfileslib "github.com/sh1Nome/dotfiles/setup/dotfileslib"
)

func main() {
	// DotfilesManagerの初期化
	manager := dotfileslib.NewDotfilesManager()

	// 削除対象のリンク一覧
	links := manager.ManagedDotfileDests()

	// 削除処理
	for _, link := range links {
		info, err := os.Lstat(link)
		if err != nil {
			fmt.Printf("%s は存在しません。\n", link)
			continue
		}
		if info.Mode()&os.ModeSymlink != 0 || info.IsDir() {
			if err := os.RemoveAll(link); err != nil {
				fmt.Printf("%s の削除に失敗しました: %v\n", link, err)
			} else {
				fmt.Printf("%s を削除しました。\n", link)
			}
		} else {
			fmt.Printf("%s はシンボリックリンクでもディレクトリでもありません。\n", link)
		}
	}

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを削除しました。")
	manager.ShowDotfilesLinks()

	// 完了メッセージ
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
