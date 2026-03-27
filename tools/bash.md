alias k=kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k

EDITOR=vim

alias kgpa='kubectl get pods -A'
alias kga='kubectl get all -A'
do='--dry-run=client -o yaml'
now="--force --grace-period 0"   # k delete pod x $now


# set -o vi | emacs
# v (command mode)
# source ~/.bashrc
