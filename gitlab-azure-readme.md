## Overview of the GitLab CI/CD Pipeline for Deploying to Azure AKS
This GitLab CI pipeline automates the process of building, pushing, and deploying Docker images to an Azure Kubernetes Service (AKS) cluster. The process includes stages for building the application, deploying it to a development environment, and manual approval steps for deploying to staging and production environments. The AKS cluster has been provisioned via Terraform.

## Key Components of the Pipeline
1. Variables:

    * Azure credentials: Used to authenticate with Azure for interacting with resources like AKS and ACR.

    * AKS and ACR: Azure Kubernetes Service (AKS) and Azure Container Registry (ACR) configurations are set to push and deploy the app container.

2. Stages:

    * Build: Builds the Docker image for the application.

    * Deploy:

        * dev: Deploys the app to the development environment.

        * stage: Deploys to staging environment with manual approval.

        * prod: Deploys to production environment with manual approval.

## Detailed Procedure of the Pipeline
1. Building the Docker Image
    * The pipeline starts with the build stage. It uses the docker:latest image and Docker-in-Docker (docker:dind) service.

    * The following steps are executed:

        * Login to Azure Container Registry (ACR): Using the service principal credentials, the pipeline logs in to the Azure Container Registry (ACR) to push the Docker image.
 
        * Build Docker Image: The docker build command is executed to build the Docker image with the tag myapp:$ENVIRONMENT (where $ENVIRONMENT is the commit SHA or the environment name).

        * Push the Image to ACR: The built image is then tagged and pushed to the Azure Container Registry (proj1registry.azurecr.io).

2. Deploying to Development (dev)
    * In the deploy_dev stage, the following steps take place:

        * Login to Azure: Authenticating with Azure using the service principal.

        * Configure AKS Credentials: AKS credentials are fetched using az aks get-credentials  interact with the Kubernetes cluster.
        
        * Install Necessary Tools: The pipeline installs git and docker using apk to ensure that the necessary tools are available.
         
        * Deploy the Application: The kubectl command is used to apply Kubernetes manifests (deployment.yaml and service.yaml) to the AKS cluster to deploy the application.
         
        * Set Docker Image: The Docker image is updated in the AKS deployment using kubectl set image. The new image, built earlier, is pulled from ACR.
         
        * Restart Deployment: The Kubernetes deployment is restarted to pick up the new image.

3. Deploying to Staging (stage)
    * In the deploy_stage stage, the following happens:

        * Manual Approval: The deployment to the staging environment requires manual approval. A GitLab user must click the "Play" button in the UI to approve the deployment.

        * Deploy to AKS: Once approved, the steps are similar to the dev environment:

            * The image is deployed to the staging environment (kubectl set image and kubectl rollout restart).

        * Environment Context: The environment name is dynamically set using $ENVIRONMENT, which is set based on the branch or commit reference.

4. Deploying to Production (prod)
    * The deploy_prod stage follows the same process as the staging deployment but also requires manual approval.

        * Manual Approval: The deployment to production requires explicit approval from a user.

        * Production Deployment: After approval, the same kubectl commands are used to deploy the new image to the production AKS environment.

5. Pipeline Execution Flow
    * Build Stage: This stage always runs first to build the image and push it to ACR.
    
    * Deploy to Development: This is automatic and happens right after the build stage.
     
    * Deploy to Staging: This requires manual approval. The deployment only occurs if the "Play" button is clicked.
     
    * Deploy to Production: After staging approval, manual approval is required to trigger the production deployment.

6. Manual Approval Mechanism
    * The deployment to staging and production environments uses the when: manual keyword. This means that the pipeline will pause at these stages, and the user must click the Play button in GitLab's UI to approve the deployment.
    
    * If the Play button isn't clicked, the job will remain in the "pending" state and will not proceed.
    
    * The allow_failure: false ensures that if the manual job is not approved, the pipeline will fail at this stage.

7. Azure AKS Integration
    * Terraform: The AKS cluster is provisioned using Terraform, meaning the cluster infrastructure is already set up and managed using Terraform scripts.
    
    * Azure CLI: In the pipeline, the Azure CLI is used to authenticate, manage resources, and retrieve the AKS cluster credentials (az aks get-credentials).
     
    * Kubernetes: kubectl is used to interact with the AKS cluster, applying Kubernetes manifests to create deployments and services for the application.

## Conclusion
This GitLab CI pipeline provides an automated mechanism for building, deploying, and approving deployment of applications to Azure AKS clusters. It integrates well with Azure’s container services and ensures that deployments can be tested in a development environment before being approved for staging and production. The use of manual approval ensures that critical stages like production deployments are controlled.
