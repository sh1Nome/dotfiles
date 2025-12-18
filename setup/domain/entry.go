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
		// fcitx5
		{Name: "fcitx5", SrcRel: "dot_config/fcitx5", DstRel: ".config/fcitx5"},
		// wezterm
		{Name: "wezterm.lua", SrcRel: "dot_config/wezterm/wezterm.lua", DstRel: ".config/wezterm/wezterm.lua"},
		// bash
		{Name: ".bashrc", SrcRel: "dot_config/bash/bashrc", DstRel: ".bashrc"},
		{Name: ".bashrc.local", SrcRel: "dot_config/bash/bashrc.local", DstRel: ".bashrc.local"},
		// mise
		{Name: "mise", SrcRel: "dot_config/mise", DstRel: ".config/mise"},
		// vim
		{Name: "vimrc", SrcRel: "dot_config/vim/vimrc", DstRel: ".config/vim/vimrc"},
		// nvim
		{Name: "nvim", SrcRel: "dot_config/nvim", DstRel: ".config/nvim"},
		// git
		{Name: "config", SrcRel: "dot_config/git/config", DstRel: ".config/git/config"},
		{Name: "config.local", SrcRel: "dot_config/git/config.local", DstRel: ".config/git/config.local"},
		// lazygit
		{Name: "config.yml", SrcRel: "dot_config/lazygit/config-linux.yml", DstRel: ".config/lazygit/config.yml"},
		// vscode
		{Name: "settings.json", SrcRel: "dot_config/Code/User/settings.json", DstRel: ".config/Code/User/settings.json"},
		{Name: "keybindings.json", SrcRel: "dot_config/Code/User/keybindings.json", DstRel: ".config/Code/User/keybindings.json"},
	}
}

// WindowsManagedDotfiles はWindows用のdotfilesエントリ一覧を返す
func WindowsManagedDotfiles() []DotfileEntry {
	return []DotfileEntry{
		// wezterm
		{Name: ".wezterm.lua", SrcRel: "dot_config/wezterm/wezterm.lua", DstRel: ".wezterm.lua"},
		// bash
		{Name: ".bashrc", SrcRel: "dot_config/bash/bashrc", DstRel: ".bashrc"},
		{Name: ".bashrc.local", SrcRel: "dot_config/bash/bashrc.local", DstRel: ".bashrc.local"},
		// powershell
		{Name: "Microsoft.PowerShell_profile.ps1", SrcRel: "dot_config/powershell/Microsoft.PowerShell_profile.ps1", DstRel: "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"},
		{Name: ".profile.local.ps1", SrcRel: "dot_config/powershell/profile.local.ps1", DstRel: "Documents/WindowsPowerShell/.profile.local.ps1"},
		// mise
		{Name: "mise", SrcRel: "dot_config/mise", DstRel: ".config/mise"},
		// vim
		{Name: ".vimrc", SrcRel: "dot_config/vim/vimrc", DstRel: ".vimrc"},
		// nvim
		{Name: "nvim", SrcRel: "dot_config/nvim", DstRel: "AppData/Local/nvim"},
		// git
		{Name: "config", SrcRel: "dot_config/git/config", DstRel: ".config/git/config"},
		{Name: "config.local", SrcRel: "dot_config/git/config.local", DstRel: ".config/git/config.local"},
		// lazygit
		{Name: "config.yml", SrcRel: "dot_config/lazygit/config-windows.yml", DstRel: "AppData/Local/lazygit/config.yml"},
		// vscode
		{Name: "settings.json", SrcRel: "dot_config/Code/User/settings.json", DstRel: "AppData/Roaming/Code/User/settings.json"},
		{Name: "keybindings.json", SrcRel: "dot_config/Code/User/keybindings.json", DstRel: "AppData/Roaming/Code/User/keybindings.json"},
	}
}
