Deploying Cognizen on Azure

Initial prototype code for deploying Cognizen on Azure

The script `CognizenDeployDemo.ps1` will set up a storage account and upload the installation payload and configuration script to this storage account. SAS urls are passed to the template to download these components to the VM and start deployment.

In order to run the script, you need to have the [AzureRm PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-5.0.0) module 

Then run (to deploy to Azure US Goverment):

```commandline
.\CognizenDeployDemo.ps1 -PayloadPath <PATH TO cognizen.zip> -AdminUsername cognizen -AdminPassword <ADMIN PASSWORD> -Environment AzureUsGovernment
```

or (to deploy to Azure Commercial):

```commandline
.\CognizenDeployDemo.ps1 -PayloadPath <PATH TO cognizen.zip> -AdminUsername cognizen -AdminPassword <ADMIN PASSWORD> -Environment AzureCloud
```

You will be promped for your Azure credentials.

If you need an account, you can get a [free trial account](https://azure.microsoft.com/en-us/free/)