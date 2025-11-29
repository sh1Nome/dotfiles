package tool

import (
	"fmt"
	"os"
	"path/filepath"
)

// RemoveVimDataDir はvimデータディレクトリを削除する
func RemoveVimDataDir(homeDir, osType string) error {
	var vimDir, nvimDataDir string
	if osType == "windows" {
		vimDir = filepath.Join(homeDir, "vimfiles")
		nvimDataDir = filepath.Join(homeDir, "AppData", "Local", "nvim-data")
	} else {
		vimDir = filepath.Join(homeDir, ".vim")
		nvimDataDir = filepath.Join(homeDir, ".local", "share", "nvim")
	}

	// vimディレクトリ削除
	if _, err := os.Stat(vimDir); os.IsNotExist(err) {
		fmt.Printf("%s は存在しません。\n", vimDir)
	} else if err := os.RemoveAll(vimDir); err != nil {
		fmt.Fprintf(os.Stderr, "%s の削除に失敗しました: %v\n", vimDir, err)
		return err
	} else {
		fmt.Printf("%s を削除しました。\n", vimDir)
	}

	// nvimデータディレクトリ削除
	if _, err := os.Stat(nvimDataDir); os.IsNotExist(err) {
		fmt.Printf("%s は存在しません。\n", nvimDataDir)
	} else if err := os.RemoveAll(nvimDataDir); err != nil {
		fmt.Fprintf(os.Stderr, "%s の削除に失敗しました: %v\n", nvimDataDir, err)
		return err
	} else {
		fmt.Printf("%s を削除しました。\n", nvimDataDir)
	}
	return nil
}
