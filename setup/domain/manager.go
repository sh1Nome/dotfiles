package domain

// Manager はdotfiles管理の高レベルロジックを担当する
type Manager struct {
	linkManager           LinkManager
	dotfilesDir           string
	homeDir               string
	managedDotfileEntries []DotfileEntry
	osType                string
}

// NewManager はManagerを初期化して返す
func NewManager(linkManager LinkManager, dotfilesDir, homeDir, osType string) *Manager {
	var managedDotfileEntries []DotfileEntry
	switch osType {
	case "linux":
		managedDotfileEntries = LinuxManagedDotfiles()
	case "windows":
		managedDotfileEntries = WindowsManagedDotfiles()
	}

	return &Manager{
		linkManager:           linkManager,
		dotfilesDir:           dotfilesDir,
		homeDir:               homeDir,
		managedDotfileEntries: managedDotfileEntries,
		osType:                osType,
	}
}

// CreateDotfileLinks はシンボリックリンクを作成する
func (m *Manager) CreateDotfileLinks() {
	m.linkManager.CreateLinks(m.dotfilesDir, m.homeDir, m.managedDotfileEntries)
}

// RemoveDotfileLinks はシンボリックリンクを削除する
func (m *Manager) RemoveDotfileLinks() {
	m.linkManager.RemoveLinks(m.homeDir, m.managedDotfileEntries)
}

// ShowDotfilesLinks はシンボリックリンク一覧を表示する
func (m *Manager) ShowDotfilesLinks() {
	m.linkManager.ShowLinks(m.homeDir, m.osType, m.managedDotfileEntries)
}
