package domain

// DotfileEntry はdotfiles管理ファイルの情報を表す
type DotfileEntry struct {
	Name   string // ファイル名またはディレクトリ名
	SrcRel string // dotfilesディレクトリからの相対パス
	DstRel string // ホームディレクトリからの相対パス
}

// LinuxManagedDotfiles はLinux用のdotfilesエントリ一覧を返す
func LinuxManagedDotfiles() []DotfileEntry {
	return []DotfileEntry{
		// bash
		{Name: ".bashrc", SrcRel: ".bashrc", DstRel: ".bashrc"},
		// mise
		{Name: "mise", SrcRel: "dot_mise", DstRel: ".config/mise"},
		// vim
		{Name: ".vimrc", SrcRel: ".vimrc", DstRel: ".vimrc"},
		// nvim
		{Name: "nvim", SrcRel: "nvim", DstRel: ".config/nvim"},
		// git
		{Name: ".gitconfig", SrcRel: ".gitconfig", DstRel: ".gitconfig"},
		{Name: ".gitconfig.local", SrcRel: ".gitconfig.local", DstRel: ".gitconfig.local"},
		// vscode
		{Name: "settings.json", SrcRel: "vscode/settings.json", DstRel: ".config/Code/User/settings.json"},
		{Name: "keybindings.json", SrcRel: "vscode/keybindings.json", DstRel: ".config/Code/User/keybindings.json"},
	}
}

// WindowsManagedDotfiles はWindows用のdotfilesエントリ一覧を返す
func WindowsManagedDotfiles() []DotfileEntry {
	return []DotfileEntry{
		// bash
		{Name: ".bashrc", SrcRel: ".bashrc", DstRel: ".bashrc"},
		// mise
		{Name: "mise", SrcRel: "dot_mise", DstRel: ".config/mise"},
		// powershell
		{Name: "Microsoft.PowerShell_profile.ps1", SrcRel: "Microsoft.PowerShell_profile.ps1", DstRel: "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"},
		// vim
		{Name: ".vimrc", SrcRel: ".vimrc", DstRel: ".vimrc"},
		// nvim
		{Name: "nvim", SrcRel: "nvim", DstRel: "AppData/Local/nvim"},
		// git
		{Name: ".gitconfig", SrcRel: ".gitconfig", DstRel: ".gitconfig"},
		{Name: ".gitconfig.local", SrcRel: ".gitconfig.local", DstRel: ".gitconfig.local"},
		// vscode
		{Name: "settings.json", SrcRel: "vscode/settings.json", DstRel: "AppData/Roaming/Code/User/settings.json"},
		{Name: "keybindings.json", SrcRel: "vscode/keybindings.json", DstRel: "AppData/Roaming/Code/User/keybindings.json"},
	}
}
