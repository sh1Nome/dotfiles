package usecase

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/domain/tool"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// ExecuteUnlink はunlinkユースケースを実行する
func ExecuteUnlink() error {
	manager := domain.NewManager()

	// 管理しているdotfilesのリンク削除
	manager.RemoveDotfileLinks()

	// .gitconfig.localの削除
	dotfilesDir := infrastructure.GetDotfilesDir()
	if err := tool.RemoveGitConfigLocal(dotfilesDir); err != nil {
		return err
	}

	// vimデータディレクトリの削除
	homeDir := infrastructure.GetHomeDir()
	osType := infrastructure.GetOSType()
	if err := tool.RemoveVimDataDir(homeDir, osType); err != nil {
		return err
	}

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを削除しました。")

	return nil
}
