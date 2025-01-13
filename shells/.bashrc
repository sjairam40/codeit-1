#eval "$(starship init bash)"
#eval "$(logcli --completion-script-bash)"

. .bash_profile

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

echo " Load kube config"
export KUBECONFIG=~/.kube/config

# Add KREW to path
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/kubectl-plugin:$PATH"

# Add codeit/bin to PATH
export PATH=$PATH:/Users/sjairam/Documents/GitHub/PERS/codeit/bin
echo " --> added codeit"

##Kubectl Plugins
export PATH=$PATH:/Users/sjairam/Documents/GitHub/TOOLS/kubectl-plugins
echo " --> added kubectl plugins"

export PATH=$PATH:/usr/local/bin/
## KUBE PS1
source "/Users/sjairam/Downloads/kube-ps1-0.8.0/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
echo " added kube ps"

## Add Istio 1.22.6 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.22.6/bin
#echo " added istio 1.22.6"

# Add Istio 1.22.7 to PATH
#export PATH=$PATH:/Users/sjairam/istio-1.22.7/bin
#echo " added istio 1.22.7"

# Add Istio 1.23.4 to PATH
export PATH=$PATH:/Users/sjairam/istio-1.23.4/bin
echo " added istio 1.23.4"

#Add .scripts to PATH
export PATH=$PATH:/Users/sjairam/.scripts
echo " --> added scripts"

echo " Load keys"
ssh-add ~/.ssh/id_harvard
ssh-add ~/.ssh/id_rsa_202409
source /Users/sjairam/perl5/perlbrew/etc/bashrc

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/sjairam/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
