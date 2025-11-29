package common

import (
	"fmt"
)

// PromptForEnter はEnterキーの入力を待機する
func PromptForEnter() {
	fmt.Println("Enterを押して終了します...")
	var input string
	fmt.Scanln(&input)
}
