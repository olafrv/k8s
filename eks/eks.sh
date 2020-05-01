
# Kubeconfig
aws sts get-caller-identity
rm -rf .kube
aws eks update-kubeconfig --name webeks --region us-east-1
kubectl get svc
kubectl config view --minify

# Cluster Creator User - AWS Auth for Other Users
aws sts get-caller-identity
rm -rf .kube;
aws eks update-kubeconfig --name webeks --region us-east-1 --profile olafrv
kubectl describe configmap -n kube-system aws-auth
#curl -o aws-auth-cm.yaml https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-03-23/aws-auth-cm.yaml
kubectl -f aws-auth.yaml apply

