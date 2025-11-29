package usecase

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/domain/tool"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// UnlinkUsecase はシンボリックリンク削除のユースケースを実行する
type UnlinkUsecase struct {
	manager *domain.Manager
}

// NewUnlinkUsecase はUnlinkUsecaseを初期化して返す
func NewUnlinkUsecase() *UnlinkUsecase {
	return &UnlinkUsecase{
		manager: domain.NewManager(),
	}
}

// Execute はunlinkユースケースを実行する
func (u *UnlinkUsecase) Execute() error {
	// 管理しているdotfilesのリンク削除
	u.manager.RemoveDotfileLinks()

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
