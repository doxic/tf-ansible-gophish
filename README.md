## Install AWS CLI
```
pip install awscli
python3 -m pip install awscli wheel pyyaml
```

```
aws configure
```

## Install Terraform
```
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
unzip terraform*.zip -d ~/bin/
chmod +x ~/bin/terraform
```

## terraform.tfvars
```
cat << EOF > terraform.tfvars
hcloud_token = ""
cloudflare_email = ""
cloudflare_token = ""
EOF
```


## Run

Create server by running:

TF_VAR_hcloud_token=YOUR_SECRET_TOKEN
terraform init
terraform plan
terraform apply
terraform destroy

## Providers
### Cloudflare
https://www.terraform.io/docs/providers/cloudflare/index.html
https://blog.cloudflare.com/getting-started-with-terraform-and-cloudflare-part-1/


## Provision with Ansible
```
wget  https://raw.githubusercontent.com/hg8496/ansible-hcloud-inventory/master/hcloud.py
chmod +x hcloud.py
export HCLOUD_TOKEN=example
```
Run ansible ping
```
"tag_App_backend:&tag_Environment_staging:&tag_Usage_clock_worker" -m ping all
ansible -i ./hcloud.py -m ping group-webserver
```

[Finding a Quick Start AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html#finding-an-ami-aws-cli)
https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean
https://docs.hetzner.cloud/
