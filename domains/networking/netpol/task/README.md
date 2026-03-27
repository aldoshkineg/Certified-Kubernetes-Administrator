# Question

## Task 1

In the secure-app namespace, apply a NetworkPolicy that first denies all incoming traffic to all pods.
Then, create a second policy that allows pods with the label component: api to receive
traffic only on TCP port 8443 from pods with the label tier: frontend within the same namespace.


## Task 2

In the monitoring namespace, create a NetworkPolicy named allow-prometheus.
It should allow only pods in the namespace labeled `source: internal` to connect to pods in
the monitoring namespace on TCP port 9090. Access from any other namespace or to any other port must be blocked.
