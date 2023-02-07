# Automanage Workshop

Repository for hands-on training with Azure Automanage and Automanage Machine Configuration

## Getting Started

### Automanage basics

Azure Automanage machine best practices is a service that eliminates the need to discover, know how to onboard, and how to configure certain services in Azure that would benefit your virtual machine. These services are considered to be Azure best practices services, and help enhance reliability, security, and management for virtual machines. Example services include Azure Update Management and Azure Backup.

[Azure Automanage documentation](https://learn.microsoft.com/en-us/azure/automanage/)

#### Deploy the test environment

Click on the Deploy to Azure button to start the deployment of the test environment.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fm-puolitaival%2FAutomanageWorkshop%2Fmain%2Fsrc%2FdeploymentTemplate.json)

After clicking the link and signing in to your Azure environment, you should be greeted with a page with contents similar to this:

![Template deployment](.img\basics_1.png)

Create a new Resource Group for the test environment, select a Region where you would like to have the test resources to be deployed and adjust the parameters as you see fit. After adjusting the parameters, click on `review+create` and after the validation has passed click on `create`. Wait for the template deployment to finish (should take only a few minutes).

As a part of the deployment a custom Automanage profile will be created. For more information about custom profiles, please refer to [Automanage documentation about custom profiles](https://learn.microsoft.com/en-us/azure/automanage/virtual-machines-custom-profile).

#### Onboarding VM(s) to Automanage manually

Go to the [Automanage page](https://portal.azure.com/#view/Microsoft_Azure_AutomanagedVirtualMachines/AutomanageMenuBlade/~/overview) and then familiarize yourself with the Automanage machines and Configuration profiles pages. On the Configuration profiles page you should see the custom profile you deployed in the previous step and you can review the settings from the pany you can open by clicking on the profile name. Check the subscription filtering from the subscription picker if you can't see the profile.

To onboard the VM to the Automanage, go back to the Automanage machines page and click on the `+ Enable on existing machine` button from the top of the page.

In the first dialog that appears, select the custom profile that you deployed.

![Select Profile](.img\basics_2.png)

On the next page, select the VM(s) you would like to onboard with the custom profile.

![Select VM(s)](.img\basics_3.png)

Click on `review+create` and after the validation has passed click on `create`. Onboarding the VM(s) will take some minutes and you can check the progress from the Automanage machines page.

#### Creating a maintenance schedule for updates

For this test environment we are going to implement the Azure Automation Accounts Update Management for updating the Virtual Machine OS. You can find the Automation Account from the Resource Group which you created at the beginning. The Automation Account should be named as Automanage-Automation-(random number).

Go to the Automation Account and to the Update Management pane. Depending on the refresh cycle, the VM(s) you deployed might be already visible on the Machines tab of the Update Management

![VMs in UM](.img\basics_4.png)

In order to enable automated patching of the VM(s) you need to create a Deployment Schedule that is associated with the VM(s). To create a schedule, click on the `Schedule update deployment` button from the top of the page.

In the New update deployment dialog you need to give the schedule a name, scope the resources to be updated and then determine the schedule. You can either assign the update schedule directly to the machine or create a group that targets the subscription/resource group in which the VM(s) reside to include all VM(s) within the give scope, and optionally filtering based on locations or tags, to the update deployment.

Next, create a schedule for the update deployment by clicking on the `Schedule settings`. Explore the options available, but create a new schedule using the hourly update deployment for testing purposes. Set the start time to happen after in the next 10 minutes.

Once all required settings have been configured, click on the `create` button to finish creating the update deployment.

![UM schedule](.img\basics_5.png)

Proceed to the next step, but remember to check back after a while to verify that the VM(s) have been updated correctly.

### Automanage Machine Configutation

Second part of the test focuses on [Automanage Machine Configurations](https://learn.microsoft.com/en-us/azure/governance/machine-configuration/) Azure Policy's machine configuration feature provides native capability to audit or configure operating system settings as code, both for machines running in Azure and hybrid Arc-enabled machines. The feature can be used directly per-machine, or at-scale orchestrated by Azure Policy.

Configuration resources in Azure are designed as an extension resource. You can imagine each configuration as an additional set of properties for the machine. Configurations can include settings such as:

- Operating system settings
- Application configuration or presence
- Environment settings

Configurations are distinct from policy definitions. Machine configuration utilizes Azure Policy to dynamically assign configurations to machines. You can also assign configurations to machines manually, or by using other Azure services such as Automanage.

#### Creating a custom Machine Configuration

To save time this test environment comes with one custom machine configuration that we are going to apply for one of the test VMs. The configuration can be found from `src\dsc\SoftwareInstallation.ps1` if you would like to review it. For more information on how to create and deploy custom Machine Configurations manually or at scale, please refer to the [documentation](https://learn.microsoft.com/en-us/azure/governance/machine-configuration/machine-configuration-create-setup).

To get started with assigning the custom configuration to VM(s), first you need to make the configuration package accessible via HTTPS. For testing purposes we are going to upload the package to Azure Storage Account and making it accessible with a SAS token.

Go to the Resource Group you created in the first step and find the Storage Account that was created as a part of the initial deployment. Inside the Storage Account resource, go to the Containers tab and create a new container named as `guestconfiguration` accepting the default settings. Go to the container after it has been created and upload the `src\dsc\SoftwareInstallation.zip` package. 

Right-click on the SoftwareInstallation.zip file and select Generate SAS. That should open up a dialog for creating a SAS token for accessing this file. In the SAS dialog, set the expiry time to some time in the future, click on the `Generate SAS token and URL` button and copy the Blob SAS URL to your notes. You will need it in the next step.

![SAS dialog](.img\basics_6.png)

After you have noted down the SAS token, click on the Deploy to Azure button to start the custom Machine Configuration deployment 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fm-puolitaival%2FAutomanageWorkshop%2Fmain%2Fsrc%2FguestConfigurationCustom.json)

You should be greeted with the following dialog:

![Template deployment](.img\basics_7.png)

Select the Resource Group you created in the first step, type the VM name you would like to assing the custom configuration package to and then copy the SAS URL you created in the previous step. Click `review+create` and after the validation has passed click on `create`. Wait for the template deployment to finish (should take only a minute).

After the deployment you can see the status of the assignment from the [Guest Assignments page](https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Compute%2FvirtualMachines%2Fproviders%2FguestConfigurationAssignments). 

Once the VM reports a compliant status, you should be able to see the installation taking place at the Change Tracking view of the VM and PowerShell 7 should be listed at the VM inventory view.
