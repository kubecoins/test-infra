# Prow Infra for Kubecoins

## Pre-Req
Download 1Password CLI
Signin in to 1password for example:
```bash
eval $(op signin companyabc someone@somewhere.com)
```

Instead of supplying command line args you can set the following environment variables:

OP_SIGNIN_ADDRESS
OP_EMAIL_ADDRESS
OP_SECRET_KEY
OP_MASTER_KEY
## Create the infra structure

1. Create `config/clusters/local.tfvars` which any sensitive values. For eaxmple:
```
eks_groups = [
    {
      rolearn  = "arn:aws:iam::123456789012:role/AdministratorAccess"
      username = "cx-admins"
      groups   = ["system:masters"]
    },
  ]
```

1. Apply the clusters TF
make tf-apply

2. Create access key for kubecoins-prow-s3 users

3. create `config/prow/service-account.json` with the format defined here:
https://github.com/kubernetes/test-infra/blob/master/prow/io/providers/providers.go#L49

//    {
//      "region": "us-east-1",
//      "s3_force_path_style": true,
//      "access_key": "access_key",
//      "secret_key": "secret_key"
//    }

make prow-s3-credentials

2. Install EBS CSI driver

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"


3. Create OAuth app and secrets (https://github.com/kubernetes/test-infra/blob/master/prow/cmd/deck/github_oauth_setup.md)
   * `prow/github_oauth` is the GitHib OAuth settings file
   * `prow/cookie` is the cookie file

make cookie
make github-oauth

4. Create PAT in the main account and add to `config/prow/oauth_token`. It must have the following scopes:
    repo
    admin:org
    admin:repo_hook
    admin:org_hook


make oauth-token

5. Create the plugins and config:

make plugins
make update-config

6. Create jobs config
kubectl create cm jobs-config
make update-jobs

7. Get the LB address from the ingress:
kubectl get ingress ing

8. Using the bot account go to the **test-infra** repo settings  and add a webhook:
Payload URL: http://LB_ADDR_FROM_ING:8888/hook
Content Type: application/json
Secret: <<value from prow/config/hmac-token>>
Send me eveything

9. Install Prow:

make prow
(you may need to get the eks kubeconfig make kubeconfig)

10. Get the external IP of deck:
kubectl get svc deck

11. Set the alias for prow.kubecoins.com in Route53 to the LB created for Deck

## Manage the kubecoins org

This is done via https://github.com/kubernetes/test-infra/tree/master/prow/cmd/peribolos

### Pre reqs

You can initially seed the config file from an existing org by doing the following:

Clone upstream test-infra:
git clone https://github.com/kubernetes/test-infra

Run the following from the root of the cloned repo 
bazel run //prow/cmd/peribolos -- --dump kubecoins --github-token-path <<pathtoyourtestinfra>>/test-infra/config/prow/oauth-token

Job:

https://github.com/kubernetes/test-infra/blob/ff8f1843e692a305b3f9d6ec8c6554db459014ca/config/jobs/kubernetes/test-infra/test-infra-trusted.yaml


## Acknowledgements

Based on the test-infra from Kubernetes and associated Falco security work: https://github.com/falcosecurity/test-infra

And associated AWS article:
https://aws.amazon.com/blogs/opensource/how-falco-uses-prow-on-aws-for-open-source-testing/

