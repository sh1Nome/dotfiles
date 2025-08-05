package main

import (
	"bufio"
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"strings"
)

func main() {
	// dotfilesディレクトリの絶対パス取得
	exePath, err := os.Executable()
	if err != nil {
		fmt.Fprintf(os.Stderr, "実行ファイルのパス取得に失敗: %v\n", err)
		os.Exit(1)
	}
	dotfilesDir := filepath.Dir(filepath.Dir(filepath.Dir(exePath)))

	// Gitユーザー名とメールアドレスを対話的に取得
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Gitのユーザー名を入力してください: ")
	gitUser, _ := reader.ReadString('\n')
	gitUser = strings.TrimSpace(gitUser)
	fmt.Print("Gitのメールアドレスを入力してください: ")
	gitEmail, _ := reader.ReadString('\n')
	gitEmail = strings.TrimSpace(gitEmail)

	// .gitconfig.local を作成・更新
	gitconfigLocalPath := filepath.Join(dotfilesDir, ".gitconfig.local")
	gitconfigLocalContent := fmt.Sprintf("[user]\n    name = %s\n    email = %s\n", gitUser, gitEmail)
	if err := os.WriteFile(gitconfigLocalPath, []byte(gitconfigLocalContent), 0644); err != nil {
		fmt.Fprintf(os.Stderr, ".gitconfig.localの作成に失敗: %v\n", err)
		os.Exit(1)
	}

	// 各種設定ファイルのシンボリックリンクを作成
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
	links := []struct{ src, dst string }{
		{filepath.Join(dotfilesDir, ".bashrc"), filepath.Join(home, ".bashrc")},
		{filepath.Join(dotfilesDir, ".vimrc"), filepath.Join(home, ".vimrc")},
		{filepath.Join(dotfilesDir, ".gitconfig"), filepath.Join(home, ".gitconfig")},
		{gitconfigLocalPath, filepath.Join(home, ".gitconfig.local")},
		{filepath.Join(dotfilesDir, "vscode/settings.json"), filepath.Join(home, ".config/Code/User/settings.json")},
		{filepath.Join(dotfilesDir, "vscode/keybindings.json"), filepath.Join(home, ".config/Code/User/keybindings.json")},
		{filepath.Join(dotfilesDir, "vscode/prompts"), filepath.Join(home, ".config/Code/User/prompts")},
	}
	_ = os.MkdirAll(filepath.Join(home, ".config/Code/User"), 0755)
	for _, l := range links {
		_ = os.Remove(l.dst)
		if err := os.Symlink(l.src, l.dst); err != nil {
			fmt.Fprintf(os.Stderr, "リンク作成失敗: %s -> %s: %v\n", l.src, l.dst, err)
		}
	}

	fmt.Println("シンボリックリンクを作成しました。\n\n現在のdotfilesシンボリックリンク一覧:")
	showDotfilesLinks(home)

	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}

func showDotfilesLinks(home string) {
	order := []string{
		".bashrc", ".vimrc", ".gitconfig", ".gitconfig.local", "settings.json", "keybindings.json", "prompts",
	}
	found := map[string]string{}
	filepath.Walk(home, func(path string, info os.FileInfo, err error) error {
		if err != nil || info == nil {
			return nil
		}
		if info.Mode()&os.ModeSymlink != 0 {
			link, err := os.Readlink(path)
			if err == nil && strings.Contains(link, "dotfiles") {
				base := filepath.Base(path)
				found[base] = fmt.Sprintf("%s -> %s", path, filepath.Base(link))
			}
		}
		return nil
	})
	for _, k := range order {
		if v, ok := found[k]; ok {
			fmt.Println(v)
			delete(found, k)
		}
	}
	if len(found) > 0 {
		fmt.Println("その他:")
		for _, v := range found {
			fmt.Println(v)
		}
	}
}
