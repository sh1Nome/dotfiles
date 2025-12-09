package tool

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// SetupGitConfigInteractive は対話内容に応じ.gitconfig.localを作成する
func SetupGitConfigInteractive(dotfilesDir string) error {
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

	gitconfigLocalPath := filepath.Join(dotfilesDir, "dot_config/git/config.local")
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

