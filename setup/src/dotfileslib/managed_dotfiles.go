package dotfileslib

import (
    "bufio"
    "fmt"
    "os"
    "os/user"
    "path/filepath"
    "strings"
    "runtime"
)

// dotfiles管理ファイルの情報
type dotfileEntry struct {
    Name   string // ファイル名
    SrcRel string // dotfilesディレクトリからの相対パス
    DstRel string // ホームディレクトリからの相対パス
}

// デフォルトのdotfilesエントリ一覧
var defaultManagedDotfileEntries = []dotfileEntry{
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
    dotfilesDir           string
    home                  string
    managedDotfileEntries []dotfileEntry
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

    // OS判定
    osType := ""
    switch os := runtime.GOOS; os {
    case "linux":
        osType = "linux"
    case "windows":
        osType = "windows"
    default:
        panic("サポートされていないOSです: " + os)
    }

    // OSによってシンボリックリンクの管理エントリを設定
    var managedDotfileEntries []dotfileEntry
    if osType == "linux" {
        managedDotfileEntries = defaultManagedDotfileEntries
    } else if osType == "windows" {
        managedDotfileEntries = nil // 必要ならwindows用のエントリを追加
    }

    return &DotfilesManager{
        dotfilesDir:           dotfilesDir,
        home:                  home,
        managedDotfileEntries: managedDotfileEntries,
    }
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

// .gitconfig.local を削除するメソッド
func (m *DotfilesManager) RemoveGitConfigLocal() error {
    gitconfigLocalPath := filepath.Join(m.dotfilesDir, ".gitconfig.local")
    if err := os.Remove(gitconfigLocalPath); err != nil {
        if os.IsNotExist(err) {
            fmt.Fprintf(os.Stderr, ".gitconfig.localは存在しません\n")
            return nil
        }
        fmt.Fprintf(os.Stderr, ".gitconfig.localの削除に失敗: %v\n", err)
        return err
    }
    fmt.Println(".gitconfig.localを削除しました")
    return nil
}

// dotfilesのシンボリックリンクを作成するメソッド
func (m *DotfilesManager) CreateDotfileLinks() {
    for _, e := range m.managedDotfileEntries {
        src := filepath.Join(m.dotfilesDir, e.SrcRel)
        dst := filepath.Join(m.home, e.DstRel)
        _ = os.Remove(dst)
        dstDir := filepath.Dir(dst)
        if _, err := os.Stat(dstDir); os.IsNotExist(err) {
            if err := os.MkdirAll(dstDir, 0755); err != nil {
                fmt.Fprintf(os.Stderr, "ディレクトリ作成失敗: %s: %v\n", dstDir, err)
                continue
            }
        }
        if err := os.Symlink(src, dst); err != nil {
            fmt.Fprintf(os.Stderr, "リンク作成失敗: %s -> %s: %v\n", src, dst, err)
        }
    }
}

// 管理しているdotfilesのリンクを削除するメソッド
func (m *DotfilesManager) RemoveDotfileLinks() {
    for _, e := range m.managedDotfileEntries {
        link := filepath.Join(m.home, e.DstRel)
        info, err := os.Lstat(link)
        if err != nil {
            fmt.Printf("%s は存在しません。\n", link)
            continue
        }
        if info.Mode()&os.ModeSymlink != 0 || info.IsDir() {
            if err := os.RemoveAll(link); err != nil {
                fmt.Printf("%s の削除に失敗しました: %v\n", link, err)
            } else {
                fmt.Printf("%s を削除しました。\n", link)
            }
        } else {
            fmt.Printf("%s はシンボリックリンクでもディレクトリでもありません。\n", link)
        }
    }
}

// dotfilesのリンク情報を表示するメソッド
func (m *DotfilesManager) ShowDotfilesLinks() {
    fmt.Println("現在のdotfilesシンボリックリンク一覧:")
    // 管理しているdotfilesの設定ファイル名を取得
    order := make([]string, 0, len(m.managedDotfileEntries))
    for _, entry := range m.managedDotfileEntries {
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
