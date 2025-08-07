package dotfileslib

import "path/filepath"

// dotfiles管理ファイルの情報
type dotfileEntry struct {
    srcRel string // dotfilesディレクトリからの相対パス
    dstRel string // ホームディレクトリからの相対パス
}

// 管理しているdotfilesのエントリ一覧
var managedDotfileEntries = []dotfileEntry{
    {".bashrc", ".bashrc"},
    {".vimrc", ".vimrc"},
    {".gitconfig", ".gitconfig"},
    {".gitconfig.local", ".gitconfig.local"},
    {"vscode/settings.json", ".config/Code/User/settings.json"},
    {"vscode/keybindings.json", ".config/Code/User/keybindings.json"},
    {"vscode/prompts", ".config/Code/User/prompts"},
}

// 管理しているdotfilesのsrc/dst絶対パスリストを返す
func ManagedDotfiles(dotfilesDir, home string) []struct{ src, dst string } {
    out := make([]struct{ src, dst string }, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, struct{ src, dst string }{
            filepath.Join(dotfilesDir, e.srcRel),
            filepath.Join(home, e.dstRel),
        })
    }
    return out
}

// 管理しているdotfilesのdst（リンク先）一覧のみを返す
func ManagedDotfileDests(home string) []string {
    out := make([]string, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, filepath.Join(home, e.dstRel))
    }
    return out
}
