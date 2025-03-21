#!/bin/bash

if [[ $(uname -m) == "x86_64" ]] || [[ $(uname -m) == "i386" ]]; then
    HOMEBREW_PREFIX="/usr/local"
elif [[ $(uname -m) == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    echo "Unknown processor architecture, exiting..."
    exit 1
fi

HOMEBREW_PATH="$HOMEBREW_PREFIX/bin/brew"
SCRIPT_PATH=$(realpath "$0")
JAVA_VERSION="17.0.11-jbr"
NODE_VERSION="18.20.7"
PYTHON_VERSION="3.11.11"
XCODE_VERSION="16.2.0"
IOS_RUNTIME="18.2"

change_shell_to_zsh() {
    echo "Changing shell to zsh..."
    if ! echo "$SHELL" | grep -q "zsh"; then
        sudo sh -c "echo $(which zsh) >> /etc/shells"
        chsh -s "$(which zsh)"
    else
        echo "Shell was already zsh!"
    fi
}

install_homebrew() {
    echo "Installing Homebrew..."
    if ! [ -x "$(command -v brew)" ]; then
        sudo echo "sudo check successful"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

download_install_brewfile() {
    echo "Downloading Brewfile..."
    curl -o Brewfile -L https://raw.githubusercontent.com/dragancla/macos-setup/main/Brewfile
    echo "Installing Brewfile..."
    eval "$($HOMEBREW_PATH shellenv)"
    brew bundle install --file=Brewfile
}

install_ohmyzsh() {
    echo "Installing Oh My Zsh..."
    rm -rf "$HOME"/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

configure_ohmyzsh() {
    echo "Cloning ZSH plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/agkozak/zsh-z "$HOME"/.oh-my-zsh/custom/plugins/zsh-z
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    
    ZSHRC="$HOME/.zshrc"

    echo "Backing up .zshrc..."
    if [ -f "$ZSHRC" ]; then
        mv "$ZSHRC" "$HOME/zshrc.bak"
    else
        echo ".zshrc file does not exist, skipping backup."
    fi

    echo "Downloading .zshrc..."
    curl -o $ZSHRC -L https://raw.githubusercontent.com/dragancla/macos-setup/main/.zshrc

    echo "Downloading .p10k.zsh..."
    curl -o $HOME/.p10k.zsh -L https://raw.githubusercontent.com/dragancla/macos-setup/main/.p10k.zsh

    printf "\n# Homebrew\neval \"\$($HOMEBREW_PATH shellenv)\"" >> $ZSHRC
    mkdir -p ~/git
}

configure_iterm() {
    echo "Downloading fonts..."
    curl -o ~/Library/Fonts/MesloLGS\ NF\ Bold\ Italic.ttf -L https://raw.githubusercontent.com/dragancla/macos-setup/main/MesloLGS%20NF%20Bold%20Italic.ttf
    curl -o ~/Library/Fonts/MesloLGS\ NF\ Bold.ttf -L https://raw.githubusercontent.com/dragancla/macos-setup/main/MesloLGS%20NF%20Bold.ttf
    curl -o ~/Library/Fonts/MesloLGS\ NF\ Italic.ttf -L https://raw.githubusercontent.com/dragancla/macos-setup/main/MesloLGS%20NF%20Italic.ttf
    curl -o ~/Library/Fonts/MesloLGS\ NF\ Regular.ttf -L https://raw.githubusercontent.com/dragancla/macos-setup/main/MesloLGS%20NF%20Regular.ttf
    echo "Downloading iTerm profile..."
    mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
    curl -o ~/Library/Application\ Support/iTerm2/DynamicProfiles/iTerm_profile.json -L https://raw.githubusercontent.com/dragancla/macos-setup/main/iTerm_profile.json
    echo "Downloading iTerm theme..."
    curl -o ~/Downloads/Cobalt2.itermcolors -L https://raw.githubusercontent.com/dragancla/macos-setup/main/iCobalt2.itermcolors
    open ~/Downloads/Cobalt2.itermcolors
}

install_android_studio() {
    echo "Installing Android Studio..."
    brew install --cask android-studio
    open -a "Android Studio"
}

install_xcode() {
    echo "Installing Xcode and runtimes..."
    brew install libimobiledevice ios-deploy ideviceinstaller xcodesorg/made/xcodes
    sudo rm /Applications/Xcode*
    xcodes install $XCODE_VERSION
    mv /Applications/Xcode-* /Applications/Xcode.app
    sudo xcode-select -s /Applications/Xcode.app
    sudo xcodebuild -license accept
    xcodes runtimes install "iOS $IOS_RUNTIME"
}

install_java() {
    echo "Installing Java..."
    brew tap sdkman/tap
    brew install sdkman-cli
    source "$HOMEBREW_PREFIX/opt/sdkman-cli/libexec/bin/sdkman-init.sh"
    yes "y" | sdk install java "$JAVA_VERSION"
    sdk use java "$JAVA_VERSION"
    sdk default java "$JAVA_VERSION"
}

install_node() {
    echo "Installing Node..."
    brew install nvm
    mkdir -p ~/.nvm
    source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    nvm install --lts "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
}

install_python() {
    echo "Installing Python..."
    brew install pyenv
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
}

if [[ "$1" = "terminal" ]]; then
    change_shell_to_zsh
    install_homebrew
    download_install_brewfile
    install_ohmyzsh
    configure_ohmyzsh
    configure_iterm
elif [[ "$1" = "java" ]]; then
    install_java
elif [[ "$1" = "node" ]]; then
    install_node
elif [[ "$1" = "python" ]]; then
    install_python
elif [[ "$1" = "xcode" ]]; then
    install_xcode
elif [[ "$1" = "android" ]]; then
    install_android_studio
else
    echo "This script will overwrite your terminal settings, use at your own risk."
    echo "Usage: bash $0 [terminal/java/node/python/xcode/android]"
    echo ""
    echo "Exiting..."
fi
