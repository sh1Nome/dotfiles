package usecase

import (
	"github.com/sh1Nome/dotfiles/setup/domain"
)

// ListUsecase はシンボリックリンク一覧表示のユースケースを実行する
type ListUsecase struct {
	manager *domain.Manager
}

// NewListUsecase はListUsecaseを初期化して返す
func NewListUsecase() *ListUsecase {
	return &ListUsecase{
		manager: domain.NewManager(),
	}
}

// Execute はlistユースケースを実行する
func (u *ListUsecase) Execute() error {
	u.manager.ShowDotfilesLinks()
	return nil
}
