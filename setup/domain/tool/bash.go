package tool

import (
	"fmt"
	"os"
	"path/filepath"
)

// SetupBashrcLocal は .bashrc.local を作成する
func SetupBashrcLocal(dotfilesDir string, miseEnv string) error {
	bashrcLocalPath := filepath.Join(dotfilesDir, ".bashrc.local")
	bashContent := fmt.Sprintf("export MISE_ENV=%s\n", miseEnv)
	if err := os.WriteFile(bashrcLocalPath, []byte(bashContent), 0644); err != nil {
		fmt.Fprintf(os.Stderr, ".bashrc.localの作成に失敗: %v\n", err)
		return err
	}
	return nil
}

