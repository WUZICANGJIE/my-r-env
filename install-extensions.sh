#!/bin/bash
# Pre-install VS Code extensions during Docker build

# List of extensions to install
EXTENSIONS=(
    "george-alisson.html-preview-vscode"
    "github.copilot"
    "github.copilot-chat"
    "github.remotehub"
    "grapecity.gc-excelviewer"
    "mechatroner.rainbow-csv"
    "ms-azuretools.vscode-containers"
    "ms-azuretools.vscode-docker"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-toolsai.datawrangler"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-wsl"
    "ms-vscode-remote.vscode-remote-extensionpack"
    "ms-vscode.azure-repos"
    "ms-vscode.powershell"
    "ms-vscode.remote-explorer"
    "ms-vscode.remote-repositories"
    "ms-vscode.remote-server"
    "rdebugger.r-debugger"
    "reditorsupport.r"
    "reditorsupport.r-syntax"
    "yzhang.markdown-all-in-one"
)

echo "Installing VS Code extensions..."
for extension in "${EXTENSIONS[@]}"; do
    echo "Installing $extension..."
    code --install-extension "$extension" --force
done

echo "All extensions installed successfully!"
