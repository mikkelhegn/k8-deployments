# Parameters
Param
    (
        # Generating a random strign for Resource Group and Cluster name if not provided
        $rndstr = ("aks-$(Get-Random)"),

        [Parameter()]    
        [String]
        $ResourceGroup = $rndstr,

        [Parameter()]
        [String]
        $ClusterName = $rndstr,
        
        # Sets the location, defaulting to EastUS
        [Parameter()]
        [String]
        $Location = "EastUS",

        # Generate a random password for the Windows nodes
        [Parameter()]
        [SecureString]
        $PasswordWin="TH$([System.Guid]::NewGuid())!@#$%",

        # Setting Windows nodepool name
        [Parameter()]
        [String]
        $WinPoolName = "winp1"
    )

# Check if resource group exists, create or return from the script
Write-Host "Creating resource group $ResourceGroup in $Location..." -ForegroundColor Green
if [ $(az group exists --name $RESOURCE_GROUP -o tsv) == 'false' ]
then
    az group create -n $RESOURCE_GROUP -l $LOCATION --query properties.provisioningState
else
    echo -e "\e[1;31mResource group $RESOURCE_GROUP already exists.\e[0m"
    echo -e "\n\e[0mPlease try again using with a new name!\e[0m\n"
    return
fi

# Create the cluster - using Azure CLI
# --windows-admin-password and --windows-admin-username is the local admin for the Windows worker nodes
# --generate-ssh-keys generates random ssh keys for SSH access
# --node-count is for the default Linux node pool
# --enable-vmss enables multiple node pools
# --network-plugin azure specifies to use Azure CNI, which is the only supported network plugin for Windows clusters
echo -e "\n\e[0mCreating cluster \e[1;32m$CLUSTER_NAME...\e[0m"
az aks create -g $RESOURCE_GROUP --name $CLUSTER_NAME  \
    --windows-admin-password $PASSWORD_WIN --windows-admin-username azureuser \
    --location $LOCATION --generate-ssh-keys --node-count 3 --enable-vmss \
    --network-plugin azure --kubernetes-version 1.14.0 --node-vm-size Standard_A1_v2 \
    --query properties.provisioningState

# Adding a Windows nodepool to the cluster
# --os-type Windows to indicate the OS type for the node pool (linux or windows)
# --node-count 3 --node-vm-size Standard_D3_v2 nu,ber of nodes and SKU for the node pool
echo -e "\e[0mAdding Windows node pool \e[1;32m$WIN_POOL_NAME..."
az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME \
    --os-type Windows --name $WIN_POOL_NAME --node-count 3 \
    --node-vm-size Standard_B4MS --kubernetes-version 1.14.0 \
    --query properties.provisioningState

echo -e '\e[1;32mDone!\e[0'