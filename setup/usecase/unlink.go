package usecase

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/domain/tool"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// ExecuteUnlink はunlinkユースケースを実行する
func ExecuteUnlink() error {
	homeDir := infrastructure.GetHomeDir()
	osType := infrastructure.GetOSType()
	dotfilesDir := infrastructure.GetDotfilesDir()

	manager := domain.NewManager(&infrastructure.Linker{}, dotfilesDir, homeDir, osType)

	// 管理しているdotfilesのリンク削除
	manager.RemoveDotfileLinks()

	// vimデータディレクトリの削除
	if err := tool.RemoveVimDataDir(homeDir, osType); err != nil {
		return err
	}

	fmt.Println("シンボリックリンクを削除しました。")

	return nil
}
