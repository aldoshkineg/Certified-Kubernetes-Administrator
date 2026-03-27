# Helm CKA

Enable Completion:
`source <(helm completion bash)`

## Repository (hub - global | repo - local)

Add repo
`helm repo add bitnami https://charts.bitnami.com/bitnami`

Update repos
`helm repo update`

List repos
`helm repo list`

Search in Artifact Hub (with repo URL)
`helm search hub --list-repo-url mysql`

Search chart in installed repo
`helm search repo nginx`

Search all chart versions
`helm search repo bitnami/nginx --versions`

Pull chart locally
`helm pull argo/argo-cd --untar -d .`

---

## Install/Upgrade/Uninstall

Install chart
`helm install myapp bitnami/nginx -f values --set=crd=true`

Dry-run install
`helm install myapp bitnami/nginx --dry-run --debug`

Install from local chart (auto-name)
`helm install --generate-name ./chart`

Upgrade release
`helm upgrade myapp bitnami/nginx`

Upgrade with values file
`helm upgrade myapp bitnami/nginx -f values.yaml`

Upgrade and reuse values (use current values)
`helm upgrade myapp bitnami/nginx --reuse-values`

Uninstall release
`helm uninstall myapp`

---

## Release Operations

List releases (all namespaces)
`helm list -A`

View revision history
`helm history myapp`

Rollback to revision
`helm rollback myapp 1`

Get manifest from revision
`helm get manifest myapp --revision 1`

---

## Inspect / View

Show default values
`helm show values bitnami/nginx`

Render templates (no install)
`helm template myapp bitnami/nginx`

Get installed manifest
`helm get manifest myapp`

---

## Chart Development

Create new chart
`helm create mychart`

Lint chart
`helm lint mychart`

Package chart
`helm package mychart`

## ApiVersion

- v1 (Helm2)
- v2 (Helm3)
