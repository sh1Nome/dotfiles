package usecase

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/domain/tool"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// LinkUsecase はシンボリックリンク作成のユースケースを実行する
type LinkUsecase struct {
	manager *domain.Manager
}

// NewLinkUsecase はLinkUsecaseを初期化して返す
func NewLinkUsecase() *LinkUsecase {
	return &LinkUsecase{
		manager: domain.NewManager(),
	}
}

// Execute はlinkユースケースを実行する
func (u *LinkUsecase) Execute() error {
	osType := infrastructure.GetOSType()

	// Windowsの場合はPowerShellの実行ポリシーを設定
	if osType == "windows" {
		if err := tool.SetPowerShellExecutionPolicy(); err != nil {
			return err
		}
	}

	// Gitユーザー名・メールアドレス取得と.gitconfig.local作成
	dotfilesDir := infrastructure.GetDotfilesDir()
	if err := tool.SetupGitConfigInteractive(dotfilesDir); err != nil {
		return err
	}

	// 管理しているdotfilesのシンボリックリンク作成
	u.manager.CreateDotfileLinks()

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを作成しました。")

	return nil
}
