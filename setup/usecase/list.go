package usecase

import (
	"github.com/sh1Nome/dotfiles/setup/domain"
)

// ExecuteList はlistユースケースを実行する
func ExecuteList() error {
	manager := domain.NewManager()
	manager.ShowDotfilesLinks()
	return nil
}
