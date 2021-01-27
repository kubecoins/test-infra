secrets:
	op get item kubecoins-prow-github-oauth | jq ".details.notesPlain" -r > out/github_oauth
	op get item kubecoins-prow-oauth-token | jq ".details.notesPlain" -r > out/oauth-token
	op get item kubecoins-prow-cookie | jq ".details.notesPlain" -r > out/cookie.txt
	op get item kubecoins-prow-hmac-token | jq ".details.notesPlain" -r > out/hmac-token
	op get item kubecoins-prow-s3-serviceaccount | jq ".details.notesPlain" -r > out/service-account.json

update-jobs:
	@$(MAKE) -C tools/update-jobs build
	tools/update-jobs/bin/update-jobs --kubeconfig kubeconfig_kubecoins-prow-test-infra --jobs-config-path config/jobs/

github-oauth-config: secrets
	kubectl create secret generic github-oauth-config --from-file=secret=./out/github_oauth --dry-run=client -o yaml | kubectl replace secret github-oauth-config -f -

oauth-token: secrets
	kubectl create secret generic oauth-token --from-file=oauth=./out/oauth-token --dry-run=client -o yaml | kubectl replace secret oauth-token -f -

cookie: secrets
	kubectl create secret generic cookie --from-file=secret=./out/cookie.txt --dry-run=client -o yaml | kubectl replace secret cookie -f -

hmac-token: secrets
	kubectl create secret generic hmac-token --from-file=hmac=./out/hmac-token --dry-run=client -o yaml | kubectl replace secret hmac-token -f - 

plugins:
	kubectl create configmap plugins --from-file=plugins.yaml=config/plugins.yaml --dry-run=client -o yaml | kubectl replace configmap plugins -f -

update-config:
	kubectl create configmap config --from-file=config.yaml=config/config.yaml --dry-run=client -o yaml | kubectl replace configmap config -f -

prow:
	kustomize build config/prow | envsubst > out/prow.yaml
	kubectl apply -f out/prow.yaml

prow-s3-credentials:
	kubectl create secret generic s3-credentials --from-file=service-account.json=./out/service-account.json --dry-run=client -o yaml | kubectl replace secret s3-credentials -f -


#### Terraform #####

tf-init:
	terraform init config/clusters
	terraform get

tf-lint: tf-init
	terraform validate config/clusters
	terraform plan -var-file config/clusters/prow.tfvars -var-file config/clusters/local.tfvars config/clusters

tf-apply: tf-lint
	terraform apply -var-file config/clusters/prow.tfvars  -var-file config/clusters/local.tfvars -auto-approve config/clusters
	terraform init -force-copy config/clusters

tf-clean: tf-init
	terraform destroy -var-file config/clusters/prow.tfvars -var-file config/clusters/local.tfvars  -auto-approve config/clusters

kubeconfig:
	aws eks --region eu-west-2 update-kubeconfig --name kubecoins-prow-test-infra --profile sts

