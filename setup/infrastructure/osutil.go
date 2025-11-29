package infrastructure

import (
	"os"
	"os/user"
	"path/filepath"
	"runtime"
)

// GetDotfilesDir は実行ファイルのパスからdotfilesDirを推定して返す
func GetDotfilesDir() string {
	exePath, err := os.Executable()
	if err == nil {
		return filepath.Dir(filepath.Dir(filepath.Dir(exePath)))
	}
	return ""
}

// GetHomeDir はホームディレクトリを返す
func GetHomeDir() string {
	usr, err := user.Current()
	if err == nil && usr != nil {
		return usr.HomeDir
	}
	return os.Getenv("HOME")
}

// GetOSType はOS種別を返す（"linux" または "windows"）
func GetOSType() string {
	switch os := runtime.GOOS; os {
	case "linux":
		return "linux"
	case "windows":
		return "windows"
	default:
		panic("サポートされていないOSです: " + os)
	}
}
