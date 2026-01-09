package tool

import (
	"fmt"
	"os"
	"path/filepath"
)

// SetupZshrcLocal は .zshrc.local を作成する
func SetupZshrcLocal(dotfilesDir string, miseEnv string) error {
	zshrcLocalPath := filepath.Join(dotfilesDir, "dot_config/zsh/zshrc.local")
	zshContent := fmt.Sprintf("export MISE_ENV=%s\n", miseEnv)
	if err := os.WriteFile(zshrcLocalPath, []byte(zshContent), 0644); err != nil {
		fmt.Fprintf(os.Stderr, ".zshrc.localの作成に失敗: %v\n", err)
		return err
	}
	return nil
}
