package domain

// LinkManager はシンボリックリンク操作のインターフェース
type LinkManager interface {
	CreateLinks(dotfilesDir string, homeDir string, entries []DotfileEntry)
	RemoveLinks(homeDir string, entries []DotfileEntry)
	ShowLinks(homeDir string, osType string, entries []DotfileEntry)
}
