# ----- CKAD Practice Environment Setup -----

# Basic kubectl aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kr='kubectl run'
alias krm='kubectl delete'
alias ke='kubectl edit'
alias kn='kubectl config set-context --current --namespace'

# Dry-run shortcut for YAML generation
export dry='--dry-run=client -o yaml'

# Quality of life: show current context in prompt
export PS1='[\u@\h \W $(kubectl config current-context 2>/dev/null)]\$ '

# Optional: clear screen on new terminal (comment out if you don't like it)
# clear

# Basic nano commands
alias n='nano'
export EDITOR=nano

# kubectl completion
source <(kubectl completion bash)
for cmd in k kg kd ka kc kr krm ke kn; do
  complete -F __start_kubectl $cmd
done
