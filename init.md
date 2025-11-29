
project=user-mrcrgtmrczzs
user=ethan.bui@tribv.cloud 
gcloud projects add-iam-policy-binding $project \
  --member="user:$user" \
    --role="roles/editor"

project=user-mrcrgtmrczzs
gcloud config set project $project --quiet

packer init .
packer validate .
packer build .

terraform init
terrafrom plan
terraform apply --auto-approve
terrafrom destroy --auto-approve
