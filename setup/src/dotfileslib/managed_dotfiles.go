package dotfileslib

import (
    "os"
    "os/user"
    "path/filepath"
)

// dotfiles管理ファイルの情報
type dotfileEntry struct {
    SrcRel string // dotfilesディレクトリからの相対パス
    DstRel string // ホームディレクトリからの相対パス
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

// DotfilesManager クラス（Goのstruct）
type DotfilesManager struct {
    DotfilesDir string
    Home        string
}

// コンストラクタ
func NewDotfilesManager() *DotfilesManager {
    // 実行ファイルのパスからdotfilesDirを推定
    exePath, err := os.Executable()
    var dotfilesDir string
    if err == nil {
        dotfilesDir = filepath.Dir(filepath.Dir(filepath.Dir(exePath)))
    }
    // ホームディレクトリ取得
    usr, err := user.Current()
    var home string
    if err != nil || usr == nil {
        home = os.Getenv("HOME")
    } else {
        home = usr.HomeDir
    }
    return &DotfilesManager{
        DotfilesDir: dotfilesDir,
        Home:        home,
    }
}

// 管理しているdotfilesのsrc/dst絶対パスリストを返す
func (m *DotfilesManager) ManagedDotfiles() []struct{ Src, Dst string } {
    out := make([]struct{ Src, Dst string }, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, struct{ Src, Dst string }{
            filepath.Join(m.DotfilesDir, e.SrcRel),
            filepath.Join(m.Home, e.DstRel),
        })
    }
    return out
}

// 管理しているdotfilesのdst（リンク先）一覧のみを返す
func (m *DotfilesManager) ManagedDotfileDests() []string {
    out := make([]string, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, filepath.Join(m.Home, e.DstRel))
    }
    return out
}
