# CRD

Find the resource name in a CRD:
```sh
kubectl api-resources

# Or

plural:
shortNames:
singular:
```

Fast create CR:
```sh
k create ns test --oyaml --dry-run=client > cr.yml
kubectl explain websites.example.com.spec >> cr.yml
k explain ippools.crd.projectcalico.org.spec --recursive
```

Delete CRD:
```
k delete websites.example.com cr-name my-blog test
k delete customresourcedefinitions.apiextensions.k8s.io websites.example.com
```
