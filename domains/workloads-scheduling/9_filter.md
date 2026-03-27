kubectl get pods --selector tier=frontend


## Jsonpath

kubectl get pods \ -o=jsonpath='{.items[0].metadata.labels.
kubernetes\.io/hostname}'


## Custom columns

kubectl get pods -A \ -o=custom-columns='DATA:spec.containers[*].image'
