package usecase

import (
	"github.com/sh1Nome/dotfiles/setup/domain"
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// ExecuteList はlistユースケースを実行する
func ExecuteList() error {
	dotfilesDir := infrastructure.GetDotfilesDir()
	homeDir := infrastructure.GetHomeDir()
	osType := infrastructure.GetOSType()

	manager := domain.NewManager(&infrastructure.Linker{}, dotfilesDir, homeDir, osType)
	manager.ShowDotfilesLinks()
	return nil
}
