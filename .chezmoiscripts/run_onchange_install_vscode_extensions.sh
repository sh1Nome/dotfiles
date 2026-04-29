#!/bin/sh
# Install VSCode extensions

# Check if code command exists
if ! command -v code &> /dev/null; then
  echo "Warning: 'code' command not found. Skipping VSCode extension installation."
  exit 0
fi

# Define extensions to install
extensions=(
  "ms-vscode-remote.vscode-remote-extensionpack"
  "github.copilot"
  "ms-ceintl.vscode-language-pack-ja"
  "asvetliakov.vscode-neovim"
  "ritwickdey.liveserver"
)

# Install each extension
for ext in "${extensions[@]}"; do
  code --install-extension "$ext"
done
