package main

import (
	"fmt"
	"os"
	"os/user"
	"path/filepath"
)

func main() {
	// ホームディレクトリの取得
	usr, err := user.Current()
	var home string
	if err != nil || usr == nil {
		home = os.Getenv("HOME")
		if home == "" {
			fmt.Fprintln(os.Stderr, "ホームディレクトリが取得できません")
			os.Exit(1)
		}
	} else {
		home = usr.HomeDir
	}

	// 削除対象のリンク一覧
	links := []string{
		filepath.Join(home, ".bashrc"),
		filepath.Join(home, ".vimrc"),
		filepath.Join(home, ".gitconfig"),
		filepath.Join(home, ".gitconfig.local"),
		filepath.Join(home, ".config/Code/User/settings.json"),
		filepath.Join(home, ".config/Code/User/keybindings.json"),
		filepath.Join(home, ".config/Code/User/prompts"),
	}

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

	fmt.Println("シンボリックリンクの削除が完了しました。")
}
