package domain

import (
	"github.com/sh1Nome/dotfiles/setup/infrastructure"
)

// Manager はdotfiles管理の高レベルロジックを担当する
type Manager struct {
	dotfilesDir           string
	homeDir               string
	managedDotfileEntries []DotfileEntry
	osType                string
}

// NewManager はManagerを初期化して返す
func NewManager() *Manager {
	dotfilesDir := infrastructure.GetDotfilesDir()
	homeDir := infrastructure.GetHomeDir()
	osType := infrastructure.GetOSType()

	var managedDotfileEntries []DotfileEntry
	if osType == "linux" {
		managedDotfileEntries = LinuxManagedDotfiles()
	} else if osType == "windows" {
		managedDotfileEntries = WindowsManagedDotfiles()
	}

	return &Manager{
		dotfilesDir:           dotfilesDir,
		homeDir:               homeDir,
		managedDotfileEntries: managedDotfileEntries,
		osType:                osType,
	}
}

// CreateDotfileLinks はシンボリックリンクを作成する
func (m *Manager) CreateDotfileLinks() {
	for _, e := range m.managedDotfileEntries {
		entry := map[string]string{
			"SrcRel": e.SrcRel,
			"DstRel": e.DstRel,
		}
		entries := []interface{}{entry}
		infrastructure.CreateLinks(m.dotfilesDir, m.homeDir, entries)
	}
}

// RemoveDotfileLinks はシンボリックリンクを削除する
func (m *Manager) RemoveDotfileLinks() {
	entries := make([]interface{}, len(m.managedDotfileEntries))
	for i, e := range m.managedDotfileEntries {
		entries[i] = map[string]string{
			"DstRel": e.DstRel,
		}
	}
	infrastructure.RemoveLinks(m.homeDir, entries)
}

// ShowDotfilesLinks はシンボリックリンク一覧を表示する
func (m *Manager) ShowDotfilesLinks() {
	entryNames := make([]string, len(m.managedDotfileEntries))
	for i, e := range m.managedDotfileEntries {
		entryNames[i] = e.Name
	}
	infrastructure.ShowLinks(m.homeDir, m.osType, entryNames)
}
