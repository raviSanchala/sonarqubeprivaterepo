# Pre-requisites for Dedicated AKS Cluster (External)

As a preparation for SonarQube externalization following items should be provisioned on request or configured using self-service portals:

1. If we want a new environment, we need to create a Configuration item for our product. Create a [Application service](https://gsk.service-now.com/home?id=kb_article&sysparm_article=KB0020820&sys_kb_id=c576445093476d1086d879ffebba1097&spa=1) for our new environment, which will be required for AKS Cluster request via Hosting Portal 

2. Create a new privilege group for the cluster using [SailPoint](https://myapps.gsk.com/identityiq/identityRequest/identityRequest.jsf)

3. Raise a [Hosting portal](https://myhosting.gsk.com/caas/aks-cluster/overview) ticket for AKS cluster-External network.

4. This is an additional requirement after the AKS team has completed the cluster creation and related hosting portal request. To enable traffic between the AKS cluster Subnet IP address and the SonarQube marketplace. We must submit a new Incident to the AKS team with the following guidelines.

    |Incident Attributes|Values|
    |-|-|
    |Service|Container Service Platform|
    |Configuration item|*Cluster-Name*|
    |Assignment group|ContainerService-L2|
    |Short Description|Enable the traffic between the new AKS cluster and the sonarqube markets place|
    |Description|Please allow traffic for the new AKS cluster to access the SonarQube marketplace link: https://update.sonarsource.org/update-center.properties. Once you provided the relevant IP address details of the cluster, transfer the incident to PerimeterSecurityCompliance-L2 ServiceNow group to enable the traffic|
    
In order to setup the SonarQube instance the config files and pipeline must first be populated with required variables from the cluster. The following file will document the steps to setup the provisioning pipeline.

## Manual

In order to setup the CICD pipeline for this application, a few actions must be performed by the managing team to setup a service account with scoped privileges.

1. Authenticate to the Kubernetes cluster and namespace

    ```sh
    az login --tenant <TENANT ID>
    az aks get-credentials --resource-group <ASK RESOURCE GROUP> --name <CLUSTER NAME>
    ```

2. Create a namespace in the Kubernetes cluster

    ```sh
    kubectl create namespace <NAMESPACE NAME>
    ```
3. Create a context for the namespace

    ```sh
    kubectl config set-context <CONTEXT NAME> \
    --namespace <NAMESPACE NAME> \
    --cluster <CLUSTER NAME> \
    --user <CLUSTER USER NAME>
    ```

4. Create a `helmsman` Service Account and Secret for the namespace, deploying the manifests from [kubernetes](../kubernetes) folder

    ```sh
    source scripts/create-helmsman-account.sh <ENVIRONMENT>
    ```

5. Get Service Account credentials for Azure DevOps service connection creation

    ```sh
    source scripts/get-helmsman-secret.sh
    ```

6. Set the appropriate namespace and cluster URI values in the [helmsman config](../charts).

7. Generate a SSL signing request with the `san.cnf` files and push tls certificate following guide in the [data directory](../data/README.md).

8. Configure SSO using [Air Portal](https://access.gsk.com/air/). 
Reference Document for [SSO Intergration](https://air.gsk.com/air/assets/docs/New%20SSO%20Integration%20Guide.pdf)

This SSO configuration is added in env=Dev,Uat and Prod environments of sonar Properties section of Helm Charts-->values.yaml file, for example values.[env].yaml 

# Steps to Automate Azure DevOps Pipelines

After the namespace is setup with base configuration items, configure the Azure DevOps project and pipelines to run from the repository triggers.

1. Create service connections as documented in the pipeline documentation [service connections](../.azure/README.md#service-connections)
2. Create pipelines for Pull Requests and Pushes linking to the `.azure/pull-request.yml` and `.azure/push-merge.yml` within the project [ADO Pipeline](https://dev.azure.com/DevOps-CorpPlatforms/eap-dso-sre/) respectively. *Be sure to configure each document disabling CI or Pipeline Validation to prevent unnecessary triggers*

Target environment for the deployment is based on the branch being updated:

* branch named “main” triggers deployment to DevTest environment
* branch named “env-uat” triggers deployment to Uat environment
* branch named “env-prod” triggers deployment to Production environment

Before deployment configuration should be validated as part of Pull Request in GitHub Cloud. In addition to peer review which can be requested when submitting Pull Request, it will trigger the run of “gsk-tech.sonarqube-ext-enterprise (PR)” pipeline. PR pipeline is using Terraform’s validate and plan features, and Helmsman dry-run option to test the configuration without applying the modifications.

# Application Gateway for Dedicated AKS Cluster (External)

Once the initial deployment of AKS Cluster is completed, we can proceed with the application gateway creation. It automatically creates an incident from ServiceNow and assigned to 'Cloud-Network-L2' team. Team will contact the product owner of the application for the below listed items.

* URL of the Application
* Load Balancer detail(name and IP address)
* Pfx certificate of the server with password
* Environment (prod/devtest)
* Which Business group will this belong to (GPT,PSC,RD,RX)
* Only port 443 is required

PFX certificate is created as documented in the Confluence [Sonarqube Sectigo TLS Certificate](https://my-gsk.atlassian.net/wiki/spaces/CORETECHDEVOPS/pages/19270775/Sonarqube+Sectigo+TLS+Certificate).It is necessary for uploading the PFX certificate, while creating the Application gateway for HTTPS listener

After successful deployment of the application, Application gateway team will handle the DNS registration for both (internal and external) networks, so it enables SonarQube instance accessible regardless of any network. it should be registered to map the target hostname (e.g., uat.sonarqube.gsk.com) to the EXTERNAL-IP address which will be registered for the Application gateway service.
    
# Install License

Login to instance and navigate to Administration / Configuration / General settings / License manager to get the server ID. Use “Set new license” to update your Sonar Source-provided license key. More details in [vendor’s documentation](https://docs.sonarqube.org/latest/instance-administration/license-administration/).

# GitHub Integration

Detailed instructions how to integrate SonarQube's integration with GitHub Enterprise and GitHub.com are available in [vendor’s documentation](https://docs.sonarqube.org/8.9/alm-integration/github-integration/).
GitHub App for SonarQube must be registered in GitHub Cloud by organization owner in [Github](https://github.com/gsk-tech).Summary of settings to be used in GitHub App form.

GitHub Enterprise for prod instance.

|Attributes|values|
|-|-|
|GitHub App name|SonarQubePRChecks|
|Homepage URL|https://sonarqube.gsk.com|
|User authorization callback URL|https://sonarqube.gsk.com|
|Webhook URL|https://sonarqube.gsk.com|
|Repository permissions |<ul><li>Checks: Read & write</li><li>Metadata: Read-only</li><li>Pull Requests: Read & write</li><li>Commit statuses: Read-only</li></ul>|

# Role Based Access Control

There are three main groups defined in MIM portal, with their purpose and privileges being described in System Access Plan:

* SG-SonarQube-Enterprise-BasicUser
* SG-SonarQube-Enterprise-RiskManager
* SG-SonarQube-Enterprise-RiskUser

All these groups have to be added using the below link [MIM Portal]( https://gsk.service-now.com/home?id=kb_article&table=kb_knowledge&sysparm_article=KB0028237&sys_kb_id=5e7569241be0ad5079252028bd4bcb44&spa=1)
For each group appropriate privileges must be granted as described in [Confluence](https://myconfluence.gsk.com/display/CORETECHDEVOPS/SonarQube+Role+Groups)


