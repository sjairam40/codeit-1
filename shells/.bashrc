#eval "$(starship init bash)"
#eval "$(logcli --completion-script-bash)"

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

echo " --> Load KUBE config"
export KUBECONFIG=~/.kube/config
export PATH="/usr/local/bin:$PATH"

## Add KREW to path
echo " --> Added KREW to Path  "
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/kubectl-plugin:$PATH"

## KUBE PS1
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
echo " --> Added KUBE ps"

## Add Istio 1.22.6 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.22.6/bin
#echo " --> Added istio 1.22.6"

## Add Istio 1.22.8 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.22.8/bin
#echo " --> Added istio 1.22.8"

## Add Istio 1.23.4 to PATH
export PATH=$PATH:/Users/sjairam/istio-1.23.4/bin
echo " --> Added istio 1.23.4"

## Add Istio 1.24.2 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.24.2/bin
#echo " added istio 1.24.2"

echo " --> Load SSH keys"
ssh-add ~/.ssh/id_harvard
ssh-add ~/.ssh/id_rsa_202409
ssh-add ~/.ssh/id_server
ssh-add ~/.ssh/id_rsa_20241210

# export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Created by `pipx` on 2024-12-12 18:59:27
export PATH="$PATH:/Users/sjairam/.local/bin"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
### export PATH="/Users/sjairam/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
