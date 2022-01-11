# kyverno-demo


[Kyverno](https://kyverno.io/#td-block-1) is a policy engine designed for Kubernetes. With Kyverno, policies are managed as Kubernetes resources and no new language is required to write policies. This allows using familiar tools such as kubectl, git, and kustomize to manage policies. Kyverno policies can validate, mutate, and generate Kubernetes resources. The [Kyverno CLI](https://kyverno.io/docs/kyverno-cli/) can be used to test policies and validate resources as part of a CI/CD pipeline.

This repository consists of kyverno policies, resource YAML's and scripts to validate the resource YAMLS against policies using kyverno CLI.
To use repo, place all your kubernetes manifest YAML files into resources folder and all your kyverno policy yaml files into policies folder. The installation of kyverno CLI and the validation of resource YAML files is done using jenkine pipeline job which uses install-kycli.sh and script.sh shell scripts behind the scenes. The pipeline job is triggered whenever there are pushes or pull requests initiated to the main branch. The pipeline job fails and sends an email if there are resources that fail to validate against the kyverno policies. 
