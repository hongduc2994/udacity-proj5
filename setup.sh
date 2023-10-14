ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
PROJECT_NAME=capstone
AWS_REGION=us-east-1
installeksctl() {
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

    sudo mv /tmp/eksctl /usr/local/bin
}

installkubectl() {
    if [[ -z $(which kubectl) ]]
    then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    else
        echo skip kubectl already installed
    fi
}

createcluster() {
    # check if cluster already exists (return something if the cluster exists, otherwise return nothing)
    local exists=$(aws eks describe-cluster \
        --name $PROJECT_NAME \
        --region $AWS_REGION
        2>/dev/null)
        
    [[ -n "$exists" ]] && { error abort cluster $PROJECT_NAME already exists; return; }

    eksctl create cluster -f ./kube_config/node_groups.yml
}

deletecluster() {
    eksctl delete cluster \
        --name $PROJECT_NAME \
        --region $AWS_REGION
}
