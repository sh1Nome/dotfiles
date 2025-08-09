package dotfileslib

import (
    "fmt"
    "os"
    "os/user"
    "path/filepath"
    "strings"
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

// dotfilesのリンク情報を表示するメソッド
func (m *DotfilesManager) ShowDotfilesLinks() {
	fmt.Println("現在のdotfilesシンボリックリンク一覧:")
    order := []string{
        ".bashrc", ".vimrc", ".gitconfig", ".gitconfig.local", "settings.json", "keybindings.json", "prompts",
    }
    found := map[string]string{}
    // ホームディレクトリ以下を全部調べて、dotfilesへのシンボリックリンクを見つける
    filepath.Walk(m.Home, func(path string, info os.FileInfo, err error) error {
        if err != nil || info == nil {
            return nil
        }
        // シンボリックリンクかつリンク先に"dotfiles"が含まれていれば記録
        if info.Mode()&os.ModeSymlink != 0 {
            link, err := os.Readlink(path)
            if err == nil && strings.Contains(link, "dotfiles") {
                base := filepath.Base(path)
                found[base] = fmt.Sprintf("%s -> %s", path, filepath.Base(link))
            }
        }
        return nil
    })
    // orderの順番で見つかったリンクを表示
    for _, k := range order {
        if v, ok := found[k]; ok {
            fmt.Println(v)
            delete(found, k)
        }
    }
    // order以外のリンクがあれば「その他」として表示
    if len(found) > 0 {
        fmt.Println("その他:")
        for _, v := range found {
            fmt.Println(v)
        }
    }
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
