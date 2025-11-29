package usecase

import (
	"fmt"

	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/domain/tool"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// ExecuteLink はlinkユースケースを実行する
func ExecuteLink() error {
	manager := domain.NewManager()
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
	manager.CreateDotfileLinks()

	// シンボリックリンクの一覧表示
	fmt.Println("シンボリックリンクを作成しました。")

	return nil
}
