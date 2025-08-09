package dotfileslib

import (
	"bufio"
    "fmt"
    "os"
    "os/user"
    "path/filepath"
    "strings"
)

// dotfiles管理ファイルの情報
type dotfileEntry struct {
    Name   string // ファイル名
    SrcRel string // dotfilesディレクトリからの相対パス
    DstRel string // ホームディレクトリからの相対パス
}

// 管理しているdotfilesのエントリ一覧
var managedDotfileEntries = []dotfileEntry{
    {Name: ".bashrc", SrcRel: ".bashrc", DstRel: ".bashrc"},
    {Name: ".vimrc", SrcRel: ".vimrc", DstRel: ".vimrc"},
    {Name: ".gitconfig", SrcRel: ".gitconfig", DstRel: ".gitconfig"},
    {Name: ".gitconfig.local", SrcRel: ".gitconfig.local", DstRel: ".gitconfig.local"},
    {Name: "settings.json", SrcRel: "vscode/settings.json", DstRel: ".config/Code/User/settings.json"},
    {Name: "keybindings.json", SrcRel: "vscode/keybindings.json", DstRel: ".config/Code/User/keybindings.json"},
    {Name: "prompts", SrcRel: "vscode/prompts", DstRel: ".config/Code/User/prompts"},
}

// DotfilesManager クラス（Goのstruct）
type DotfilesManager struct {
    dotfilesDir string
    home        string
}
// Gitユーザー名・メールアドレスを対話的に取得し.gitconfig.localを作成する
func (m *DotfilesManager) SetupGitConfigInteractive() error {
    reader := bufio.NewReader(os.Stdin)
    fmt.Print("Gitのユーザー名を入力してください: ")
    gitUser, _ := reader.ReadString('\n')
    gitUser = strings.TrimSpace(gitUser)
    fmt.Print("Gitのメールアドレスを入力してください: ")
    gitEmail, _ := reader.ReadString('\n')
    gitEmail = strings.TrimSpace(gitEmail)

    gitconfigLocalPath := filepath.Join(m.dotfilesDir, ".gitconfig.local")
    gitconfigLocalContent := fmt.Sprintf("[user]\n    name = %s\n    email = %s\n", gitUser, gitEmail)
    if err := os.WriteFile(gitconfigLocalPath, []byte(gitconfigLocalContent), 0644); err != nil {
        fmt.Fprintf(os.Stderr, ".gitconfig.localの作成に失敗: %v\n", err)
        return err
    }
    return nil
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
        dotfilesDir: dotfilesDir,
        home:        home,
    }
}

// 管理しているdotfilesのsrc/dst絶対パスリストを返す
func (m *DotfilesManager) ManagedDotfiles() []struct{ Src, Dst string } {
    out := make([]struct{ Src, Dst string }, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, struct{ Src, Dst string }{
            filepath.Join(m.dotfilesDir, e.SrcRel),
            filepath.Join(m.home, e.DstRel),
        })
    }
    return out
}

// 管理しているdotfilesのdst（リンク先）一覧のみを返す
func (m *DotfilesManager) ManagedDotfileDests() []string {
    out := make([]string, 0, len(managedDotfileEntries))
    for _, e := range managedDotfileEntries {
        out = append(out, filepath.Join(m.home, e.DstRel))
    }
    return out
}

// dotfilesのリンク情報を表示するメソッド
func (m *DotfilesManager) ShowDotfilesLinks() {
    fmt.Println("現在のdotfilesシンボリックリンク一覧:")
    // 管理しているdotfilesの設定ファイル名を取得
    order := make([]string, 0, len(managedDotfileEntries))
    for _, entry := range managedDotfileEntries {
        order = append(order, entry.Name)
    }
    found := map[string]string{}
    // ホームディレクトリ以下を全部調べて、dotfilesへのシンボリックリンクを見つける
    filepath.Walk(m.home, func(path string, info os.FileInfo, err error) error {
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