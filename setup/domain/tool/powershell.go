package tool

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// SetPowerShellExecutionPolicy はPowerShellの実行ポリシーをRemoteSignedに設定する
// RemoteSignedは「ローカルで作成したスクリプトは制限なく実行できるが、インターネット等から取得したスクリプトは署名が必要」という実行ポリシー
func SetPowerShellExecutionPolicy() error {
	cmd := exec.Command("powershell", "-Command", "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force")
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "PowerShellの実行ポリシー設定に失敗: %v\n", err)
		return err
	}
	fmt.Println("PowerShellの実行ポリシーをRemoteSignedに設定しました")
	return nil
}

// SetupProfileLocal は .profile.local.ps1 を作成する
func SetupProfileLocal(dotfilesDir string, miseEnv string) error {
	psLocalPath := filepath.Join(dotfilesDir, "dot_config/powershell/profile.local.ps1")
	psContent := fmt.Sprintf("$env:MISE_ENV = \"%s\"\n", miseEnv)
	if err := os.WriteFile(psLocalPath, []byte(psContent), 0644); err != nil {
		fmt.Fprintf(os.Stderr, ".profile.local.ps1の作成に失敗: %v\n", err)
		return err
	}
	return nil
}
