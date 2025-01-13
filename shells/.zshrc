ssh-add --apple-load-keychain ~/.ssh/id_harvard

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

export KUBECONFIG=~/.kube/config
export PATH="/usr/local/bin:$PATH"

## Add KREW to path
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/kubectl-plugin:$PATH"

##Add codeit/bin to PATH
export PATH=$PATH:/Users/sjairam/Documents/GitHub/PERS/codeit/bin

##Add .scripts to PATH
export PATH=$PATH:/Users/sjairam/.scripts

#KUBECTL Plugins
export PATH=$PATH:/Users/sjairam/Documents/GitHub/TOOLS/kubectl-plugins
echo " Added kubectl plugins"

export PATH=$PATH:/usr/local/bin/:/opt/homebrew/bin/
## KUBE PS1
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
echo "Added kube ps"

## Add Istio 1.22.6 to PATH
export PATH=$PATH:/Users/sjairam/istio-1.22.6/bin
echo " added istio 1.22.6"

# ## Add Istio 1.22.7 to PATH
# #export PATH=$PATH:/Users/sjairam/istio-1.22.7/bin
# #echo " added istio 1.22.7"


# ## Add Istio 1.23.4 to PATH
# #export PATH=$PATH:/Users/sjairam/istio-1.23.4/bin
# #echo " added istio 1.23.4"

## Add Istio 1.24.2 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.24.2/bin
#echo " added istio 1.24.2"

#ALERTMANAGER
export PATH=$PATH:/Users/sjairam/Documents/GitHub/TOOLS/alertmanager

echo " Load keys"
ssh-add ~/.ssh/id_harvard
ssh-add ~/.ssh/id_rsa_202409
ssh-add ~/.ssh/id_server
ssh-add ~/.ssh/id_rsa_20241210

export XDG_CONFIG_HOME=~
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Created by `pipx` on 2024-12-12 18:59:27
export PATH="$PATH:/Users/sjairam/.local/bin"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
### export PATH="/Users/sjairam/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
source <(alias s=switch)
