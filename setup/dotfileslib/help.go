package dotfileslib

import "fmt"

// ShowMainHelp はメインのヘルプメッセージを表示する
func ShowMainHelp() {
	fmt.Println(`usage: setup <command> [options]

Commands:
  link      Create symbolic links for dotfiles
  unlink    Remove symbolic links for dotfiles
  list      Show list of dotfile symbolic links

Options:
  --help    Show this help message

Examples:
  setup link
  setup unlink
  setup list
  setup --help
`)
}

// ShowLinkHelp はlinkサブコマンドのヘルプメッセージを表示する
func ShowLinkHelp() {
	fmt.Println(`usage: setup link [options]

Create symbolic links for dotfiles

Options:
  --help    Show this help message
`)
}

// ShowUnlinkHelp はunlinkサブコマンドのヘルプメッセージを表示する
func ShowUnlinkHelp() {
	fmt.Println(`usage: setup unlink [options]

Remove symbolic links for dotfiles

Options:
  --help    Show this help message
`)
}

// ShowListHelp はlistサブコマンドのヘルプメッセージを表示する
func ShowListHelp() {
	fmt.Println(`usage: setup list [options]

Show list of dotfile symbolic links

Options:
  --help    Show this help message
`)
}
