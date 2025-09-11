package dotfileslib

import (
    "bufio"
    "fmt"
    "os"
    "os/user"
    "os/exec"
    "path/filepath"
    "strings"
    "runtime"
    "encoding/json"
)

// dotfiles管理ファイルの情報
type dotfileEntry struct {
    Name   string // ファイル名
    SrcRel string // dotfilesディレクトリからの相対パス
    DstRel string // ホームディレクトリからの相対パス
}

// Linux用のdotfilesエントリ一覧
var linuxManagedDotfileEntries = []dotfileEntry{
    // bash
    {Name: ".bashrc", SrcRel: ".bashrc", DstRel: ".bashrc"},
    // vim
    {Name: ".vimrc", SrcRel: ".vimrc", DstRel: ".vimrc"},
    // git
    {Name: ".gitconfig", SrcRel: ".gitconfig", DstRel: ".gitconfig"},
    {Name: ".gitconfig.local", SrcRel: ".gitconfig.local", DstRel: ".gitconfig.local"},
    // vscode
    {Name: "settings.json", SrcRel: "vscode/settings.json", DstRel: ".config/Code/User/settings.json"},
    {Name: "keybindings.json", SrcRel: "vscode/keybindings.json", DstRel: ".config/Code/User/keybindings.json"},
    {Name: "prompts", SrcRel: "vscode/prompts", DstRel: ".config/Code/User/prompts"},
}

// Windows用のdotfilesエントリ一覧
var windowsManagedDotfileEntries = []dotfileEntry{
    // powershell
    {Name: "Microsoft.PowerShell_profile.ps1", SrcRel: "Microsoft.PowerShell_profile.ps1", DstRel: "Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"},
    // vim
    {Name: ".vimrc", SrcRel: ".vimrc", DstRel: ".vimrc"},
    // git
    {Name: ".gitconfig", SrcRel: ".gitconfig", DstRel: ".gitconfig"},
    {Name: ".gitconfig.local", SrcRel: ".gitconfig.local", DstRel: ".gitconfig.local"},
    // vscode
    {Name: "settings.json", SrcRel: "vscode/settings.json", DstRel: "AppData/Roaming/Code/User/settings.json"},
    {Name: "keybindings.json", SrcRel: "vscode/keybindings.json", DstRel: "AppData/Roaming/Code/User/keybindings.json"},
    {Name: "prompts", SrcRel: "vscode/prompts", DstRel: "AppData/Roaming/Code/User/prompts"},
}

// DotfilesManager クラス（Goのstruct）
type DotfilesManager struct {
    dotfilesDir           string
    home                  string
    managedDotfileEntries []dotfileEntry
    osType                string // OS種別 ("linux" or "windows")
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
        managedDotfileEntries = linuxManagedDotfileEntries
    } else if osType == "windows" {
        managedDotfileEntries = windowsManagedDotfileEntries
    }

    return &DotfilesManager{
        dotfilesDir:           dotfilesDir,
        home:                  home,
        managedDotfileEntries: managedDotfileEntries,
        osType:                osType,
    }
}

// Windows用: PowerShellの実行ポリシーをRemoteSignedに設定する
// RemoteSignedは「ローカルで作成したスクリプトは制限なく実行できるが、インターネット等から取得したスクリプトは署名が必要」という実行ポリシー
func (m *DotfilesManager) SetPowerShellExecutionPolicy() error {
    if m.osType != "windows" {
        return nil // Windows以外は何もしない
    }
    cmd := exec.Command("powershell", "-Command", "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force")
    if err := cmd.Run(); err != nil {
        fmt.Fprintf(os.Stderr, "PowerShellの実行ポリシー設定に失敗: %v\n", err)
        return err
    }
    fmt.Println("PowerShellの実行ポリシーをRemoteSignedに設定しました")
    return nil
}

// 対話内容に応じ.gitconfig.localを作成する
func (m *DotfilesManager) SetupGitConfigInteractive() error {
    reader := bufio.NewReader(os.Stdin)
    fmt.Print("Gitのユーザー名を入力してください: ")
    gitUser, _ := reader.ReadString('\n')
    gitUser = strings.TrimSpace(gitUser)
    fmt.Print("Gitのメールアドレスを入力してください: ")
    gitEmail, _ := reader.ReadString('\n')
    gitEmail = strings.TrimSpace(gitEmail)
    fmt.Print("credential.providerをgenericに設定しますか？ [y/N]: ")
    credProvider, _ := reader.ReadString('\n')
    credProvider = strings.TrimSpace(credProvider)

    gitconfigLocalPath := filepath.Join(m.dotfilesDir, ".gitconfig.local")
    gitconfigLocalContent := fmt.Sprintf("[user]\n    name = %s\n    email = %s\n", gitUser, gitEmail)
    if credProvider == "y" || credProvider == "Y" {
        gitconfigLocalContent += "[credential]\n    provider = generic\n"
    }
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

// keybindings_default.jsonとkeybindings_duo.jsonをマージしてkeybindings.jsonを出力する
func (m *DotfilesManager) GenerateKeybindingsJson() error {
    reader := bufio.NewReader(os.Stdin)
    fmt.Print("GitLab Duoを使っていますか？ [y/N]: ")
    ans, _ := reader.ReadString('\n')
    ans = strings.TrimSpace(ans)

    vscodeDir := filepath.Join(m.dotfilesDir, "vscode")
    defaultPath := filepath.Join(vscodeDir, "keybindings_default.json")
    duoPath := filepath.Join(vscodeDir, "keybindings_duo.json")
    outPath := filepath.Join(vscodeDir, "keybindings.json")

    // default読み込み
    defaultBytes, err := os.ReadFile(defaultPath)
    if err != nil {
        return fmt.Errorf("keybindings_default.jsonの読み込みに失敗: %v", err)
    }

    var defaultArr []map[string]interface{}
    if err := parseJsonArray(defaultBytes, &defaultArr); err != nil {
        return fmt.Errorf("keybindings_default.jsonのパースに失敗: %v", err)
    }

    var merged []map[string]interface{}
    merged = defaultArr

    if ans == "y" || ans == "Y" {
        // duo読み込み
        duoBytes, err := os.ReadFile(duoPath)
        if err != nil {
            return fmt.Errorf("keybindings_duo.jsonの読み込みに失敗: %v", err)
        }
        var duoArr []map[string]interface{}
        if err := parseJsonArray(duoBytes, &duoArr); err != nil {
            return fmt.Errorf("keybindings_duo.jsonのパースに失敗: %v", err)
        }
        merged = append(merged, duoArr...)
    }

    // 出力
    outBytes, err := toJsonArrayBytes(merged)
    if err != nil {
        return fmt.Errorf("keybindings.jsonの生成に失敗: %v", err)
    }
    if err := os.WriteFile(outPath, outBytes, 0644); err != nil {
        return fmt.Errorf("keybindings.jsonの書き込みに失敗: %v", err)
    }
    fmt.Printf("%s を出力しました\n", outPath)
    return nil
}

// JSON配列をパースするユーティリティ
func parseJsonArray(data []byte, out *[]map[string]interface{}) error {
    dec := json.NewDecoder(strings.NewReader(string(data)))
    return dec.Decode(out)
}

// JSON配列を[]byteで返すユーティリティ
func toJsonArrayBytes(arr []map[string]interface{}) ([]byte, error) {
    var b strings.Builder
    enc := json.NewEncoder(&b)
    enc.SetEscapeHTML(false)
    enc.SetIndent("", "  ")
    if err := enc.Encode(arr); err != nil {
        return nil, err
    }
    return []byte(b.String()), nil
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

    // Windows環境のみ、一部ディレクトリを除外（性能向上のため）
    skipDirs := map[string]struct{}{}
    if m.osType == "windows" {
        skipList := []string{
            "AppData/Local",
            "AppData/LocalLow",
            "AppData/LineCall",
            "Pictures",
            "Videos",
            "Downloads",
            "Music",
            "3D Objects",
            "Saved Games",
            "Contacts",
            "Links",
            "Searches",
            "Favorites",
        }
        for _, d := range skipList {
            skipDirs[filepath.Join(m.home, d)] = struct{}{}
        }
    }

    found := map[string]string{}
    // ホームディレクトリ以下を全部調べて、dotfilesへのシンボリックリンクを見つける
    filepath.Walk(m.home, func(path string, info os.FileInfo, err error) error {
        if err != nil || info == nil {
            return nil
        }
        // Windowsの場合のみ、不要なディレクトリをスキップ
        if m.osType == "windows" && info.IsDir() {
            if _, ok := skipDirs[path]; ok {
                return filepath.SkipDir
            }
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
