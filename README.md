# tdd-azd-monitor

Trainer-Demo-Deploy scenario for Azure Monitor including system metrics, custom logs, and external telemetry.

This template provides Azure Monitor capabilities for monitoring applications and infrastructure.

## ⬇️ Installation
- [Azure Developer CLI - AZD](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
    - When installing AZD, the above the following tools will be installed on your machine as well, if not already installed:
        - [GitHub CLI](https://cli.github.com)
        - [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
    - You need Owner or Contributor access permissions to an Azure Subscription to  deploy the scenario.

## 🚀 Cloning the scenario in 4 steps:

1. Create a new folder on your machine.
```
mkdir tdd-azd-monitor
```
2. Next, navigate to the new folder.
```
cd tdd-azd-monitor
```
3. Next, run `azd init` to initialize the deployment.
```
azd init -t kareldewinter/tdd-azd-monitor
```
4. Deploy the Azure Monitor resources using azd.
```
azd up
```

## 🚀 Push the scenario to your own GitHub:

1. Sync the new scenario you created into your own GitHub account into a public repo, using the same name as what you specified in the azure.yaml

2. Once available, add the necessary "additional demo scenario artifacts" (demoguide.md, demoguide screenshots, scenario architecture diagram,...) 

3. With all template details and demo artifacts available in the repo, follow the steps on how to [Contribute](https://microsoftlearning.github.io/trainer-demo-deploy/docs/contribute) to get your scenario published into the catalog.
