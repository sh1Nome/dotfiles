package tool

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// GetMiseEnvInteractive は対話内容に応じ miseEnvを返す
func GetMiseEnvInteractive() (string, error) {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("miseで必要最小限のツールのみを管理しますか？ [y/N]: ")
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(response)

	miseEnv := "default"
	if response == "y" || response == "Y" {
		miseEnv = "minimal"
	}

	fmt.Printf("miseの環境を '%s' に設定しました。\n", miseEnv)
	return miseEnv, nil
}

