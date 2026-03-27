# Imperative commands

Use help:
`kubectl taint --help`

View install resources:
`k get -f pod.yaml`

Diff changes of resources:
`k diff -f pod.yaml`

Extract labels:
`k get nodes --show-labels`

Fast run pod:
`k run alpine --image=alpine -- sleep 1d`

Create Job:
`kubectl create job myjob --image=busybox -- date`

Delete all in default namespace:
`k delete all --all -n default`

Show logs for pods with label:
`k logs -n default -l app=myapp --prefix`

Debug pod with copy and shared processes:
`k debug pod/busybox -it --copy-to=debug --share-processes --image=nicolaka/netshoot`

Replace resource and restart pod:
`kubectl replace -f question6.yaml --force`

Update deployment image:
`kubectl set image deployment/nginx-deployment nginx=nginx:1.21.1`

Remove label from pod:
`kubectl label pods redis-pod tier-`

Annotate pods:
`kubectl annotate po nginx1 nginx2 nginx3 description='my description'`

Create ResourceQuota (dry-run):
`kubectl create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml`

Explain pod spec:
`kubectl explain po.spec`

Create Ingress:
`kubectl create ingress myingress --rule="host/path=svc:80"`

Create PodDisruptionBudget:
`kubectl create poddisruptionbudget mypdb --min-available=1 --selector=app=myapp`

Create PriorityClass:
`kubectl create priorityclass mypriority --value=1000 --global-default=false`

Taint node:
`kubectl taint nodes master-1 node-role.kubernetes.io/control-plane:NoSchedule`

## Service

Expose deployment with custom name:
`k expose deployment cka- --selector='env=prod' --name=cka-service --port=8080 --target-port=80`

Expose on headless:
`k expose deployment my --target-port=80 --port=80 --cluster-ip=None`

Create svc nodeport (app=my) only for **dry-run**:
`k create svc nodeport my --tcp=80:8080 --node-port=31000`

Create CronJob:
`k create cronjob job --image=busybox --schedule="*/5 * * * *" -- date`

Create ClusterIP service (dry-run):
`k create svc clusterip redis --tcp=8080:9090`
