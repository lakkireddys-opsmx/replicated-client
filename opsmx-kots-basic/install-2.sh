#!/bin/bash
echo "Please provide Absolute Path for Kubeconfig File"
read VARNAME
kubeconfigpath=$VARNAME
echo ""
echo "Minimum requirements: A kubenetes cluster with minimum 32 GB RAM and 8 CPUs of free resources, internet access from the cluster and kubectl access to one namespace is required. kubectl and sudo access (root access) are required on the machine where this script is being executed."
echo ""
echo "Choose an Installation mode."
echo "Basic: Simple installation most suitable for quick look at ISD/OES. Choose this mode if we do not have access to a DNS server. Agent functionality is not available."
echo "Intermediate: Requires a DNS server. Best option if we have or want to use an ingress controller or loadbalancer for application access."
echo "Advanced: Requires a DNS server, supports HTTPS and other options for a more restrictive environment."
echo ""
echo "Select an installation mode (Basic, Intermediate or Advanced):"

read VAR
VAR=$(echo "$VAR" | awk '{print tolower($0)}')
mode=$VAR
export KUBECONFIG="$kubeconfigpath"

echo "Checking Kubectl Version"
kubectl version --short

if [ $? -eq 0 ]; then
   echo OK
   echo "Installing Replicated CLI"
   curl -s https://api.github.com/repos/replicatedhq/replicated/releases/latest \
           | grep "browser_download_url.*$(uname | tr '[:upper:]' '[:lower:]')_amd64.tar.gz" \
           | cut -d : -f 2,3 \
           | tr -d \" \
           | cat <( echo -n "url") - \
           | curl -fsSL -K- \
           | tar xvz replicated
   sudo mv replicated /usr/local/bin/
   export REPLICATED_APP=susmita-advanced
   export REPLICATED_API_TOKEN=4c3b4d8c5b4c150bc71ff27c172b9fe0e18667f4eaa3c6c36a84814a14dbc3b9
   replicated release ls
   git clone https://github.com/lakkireddys-opsmx/replicated-client.git
   cd replicated-client
   cd opsmx-kots-$mode
   replicated release create --auto -y 
   curl https://kots.io/install | bash
   kubectl kots install susmita-advanced/unstable
else
   echo "AWWWW.....kubectl is not installed. Please install kubectl"
fi
