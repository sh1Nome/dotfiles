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

	// vimデータディレクトリの削除
	homeDir := infrastructure.GetHomeDir()
	osType := infrastructure.GetOSType()
	if err := tool.RemoveVimDataDir(homeDir, osType); err != nil {
		return err
	}

	fmt.Println("シンボリックリンクを削除しました。")

	return nil
}
