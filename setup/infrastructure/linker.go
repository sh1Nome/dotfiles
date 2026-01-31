package infrastructure

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/sh1Nome/dotfiles/setup/domain"
)

// Linker はlinkManager実装
type Linker struct{}

// CreateLinks はシンボリックリンクを作成する
func (l *Linker) CreateLinks(dotfilesDir string, homeDir string, entries []domain.DotfileEntry) {
	for _, e := range entries {
		src := filepath.Join(dotfilesDir, e.SrcRel)
		dst := filepath.Join(homeDir, e.DstRel)
		_ = os.Remove(dst)
		dstDir := filepath.Dir(dst)
		if _, err := os.Stat(dstDir); os.IsNotExist(err) {
			if err := os.MkdirAll(dstDir, 0755); err != nil {
				fmt.Fprintf(os.Stderr, "ディレクトリ作成失敗: %s: %v\n", dstDir, err)
				continue
			}
		}
		if err := os.Symlink(src, dst); err != nil {
			fmt.Fprintf(os.Stderr, "リンク作成失敗: %s -> %s: %v\n", src, dst, err)
		}
	}
}

// RemoveLinks はシンボリックリンクを削除する
func (l *Linker) RemoveLinks(homeDir string, entries []domain.DotfileEntry) {
	for _, e := range entries {
		link := filepath.Join(homeDir, e.DstRel)

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
}

// ShowLinks はdotfilesのリンク情報を表示する
func (l *Linker) ShowLinks(homeDir string, osType string, entries []domain.DotfileEntry) {
	fmt.Println("現在のdotfilesシンボリックリンク一覧:")

	// Windows環境のみ、一部ディレクトリを除外（性能向上のため）
	skipDirs := map[string]struct{}{}
	if osType == "windows" {
		skipList := []string{
			"AppData/LocalLow",
			"AppData/LineCall",
			"Pictures",
			"Videos",
			"Downloads",
			"Music",
			"3D Objects",
			"Saved Games",
			"Contacts",
			"Links",
			"Searches",
			"Favorites",
		}
		for _, d := range skipList {
			skipDirs[filepath.Join(homeDir, d)] = struct{}{}
		}
	}

	found := map[string]string{}
	// ホームディレクトリ以下を全部調べて、dotfilesへのシンボリックリンクを見つける
	filepath.Walk(homeDir, func(path string, info os.FileInfo, err error) error {
		if err != nil || info == nil {
			return nil
		}
		// Windowsの場合のみ、不要なディレクトリをスキップ
		if osType == "windows" && info.IsDir() {
			if _, ok := skipDirs[path]; ok {
				return filepath.SkipDir
			}
		}
		// シンボリックリンクかつリンク先に"dotfiles"が含まれていれば記録
		if info.Mode()&os.ModeSymlink != 0 {
			link, err := os.Readlink(path)
			if err == nil && strings.Contains(link, "dotfiles") {
				base := filepath.Base(path)
				found[base] = fmt.Sprintf("%s -> %s", path, filepath.Base(link))
			}
		}
		return nil
	})
	// entriesの順番で見つかったリンクを表示
	for _, e := range entries {
		if v, ok := found[e.Name]; ok {
			fmt.Println(v)
			delete(found, e.Name)
		}
	}
	// entries以外のリンクがあれば「その他」として表示
	if len(found) > 0 {
		fmt.Println("その他:")
		for _, v := range found {
			fmt.Println(v)
		}
	}
}
