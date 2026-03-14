# Install VSCode extensions

# Check if code command exists
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host "Warning: 'code' command not found. Skipping VSCode extension installation."
  exit 0
}

# Define extensions to install
$extensions = @(
  "ms-vscode-remote.vscode-remote-extensionpack",
  "github.copilot",
  "ms-ceintl.vscode-language-pack-ja",
  "asvetliakov.vscode-neovim",
  "ritwickdey.liveserver"
)

# Install each extension
foreach ($ext in $extensions) {
  code --install-extension $ext
}
