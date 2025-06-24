# AZD Trainer-Demo-Deploy Starter template

This template could be used as a starting point for creating your own AZD-compatible templates, which you will contribute to [Trainer-Demo-Deploy](https://aka.ms/trainer-demo-deploy). 

## ⬇️ Installation
- [Azure Developer CLI - AZD](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
    - When installing AZD, the above the following tools will be installed on your machine as well, if not already installed:
        - [GitHub CLI](https://cli.github.com)
        - [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
    - You need Owner or Contributor access permissions to an Azure Subscription to  deploy the scenario.

## 🚀 Cloning the scenario in 4 steps:

1. Create a new folder on your machine.
```
mkdir tdd-azd-starter
```
2. Next, navigate to the new folder.
```
cd tdd-azd-starter
```
3. Next, run `azd init` to initialize the deployment.
```
azd init -t petender/tdd-azd-starter
```
4. Copy the starter template into its own directory and modify the template.
```
Update the main.bicep and resources.bicep with your own resource information
```
5. Update the azure.yaml metadata
```
Update the name and metadata.template parameters in the azure.yaml, with your preferred scenario name, e.g. tdd-azd-trafficmgr
```

## 🚀 Push the scenario to your own GitHub:

1. Sync the new scenario you created into your own GitHub account into a public repo, using the same name as what you specified in the azure.yaml

2. Once available, add the necessary "additional demo scenario artifacts" (demoguide.md, demoguide screenshots, scenario architecture diagram,...) 

3. With all template details and demo artifacts available in the repo, follow the steps on how to [Contribute](https://microsoftlearning.github.io/trainer-demo-deploy/docs/contribute) to Trainer-Demo-Deploy, to get your scenario published into the catalog.


 
