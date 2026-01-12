package tool

import (
	"fmt"
	"os"
	"os/exec"
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
