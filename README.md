# Build and Deploy Docker Application to AWS

This repository contains a GitHub Actions workflow to automate the build and deployment of a Docker application to AWS. The workflow consists of two main jobs: `build` and `deploy`.

## Workflow Configuration

The GitHub Actions workflow is triggered on a `push` event to the `main` branch. It performs the following steps:

### 1. Build Job

The `build` job includes the following steps:

- **Checkout Code**: Retrieves the latest code from the `main` branch.
- **Set Up AWS Credentials**: Configures AWS credentials for the session using secrets stored in GitHub.
- **Log In to Amazon ECR**: Authenticates Docker with Amazon Elastic Container Registry (ECR) to enable image pushes.
- **Build Docker Image**: Builds the Docker image for the application.
- **Tag Docker Image**: Tags the Docker image for the ECR repository.
- **Push Docker Image**: Pushes the tagged Docker image to Amazon ECR.

### 2. Deploy Job

The `deploy` job runs after the `build` job completes and includes the following steps:

- **Set Up AWS Credentials**: Reconfigures AWS credentials for deployment.
- **Update ECS Service**: Updates the Amazon ECS service with the latest task definition, applying a specified network configuration.

## Requirements

1. **AWS Secrets**: Store your AWS credentials in GitHub Secrets with the following names:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN` (if using temporary session tokens)
   - `AWS_REGION` (e.g., `us-west-2`)
   - `ECR_REPOSITORY` (Amazon ECR repository URI)

2. **AWS Resources**: Ensure that the following AWS resources are set up:
   - **Amazon ECR**: A repository to store Docker images.
   - **Amazon ECS**: A cluster and service to run the Docker container.
   - **Network Configuration**: Security groups and subnets for the ECS service.

## Usage

1. Commit and push your changes to the `main` branch.
2. The workflow will automatically build, tag, and push the Docker image to Amazon ECR.
3. The `deploy` job will then update the Amazon ECS service to use the new Docker image.

## Example Workflow File

Below is the complete GitHub Actions workflow:

```yaml
name: Build and Deploy Docker to AWS

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up AWS credentials for session
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }}
        run: |
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
          aws configure set aws_session_token $AWS_SESSION_TOKEN
          aws configure set region $AWS_DEFAULT_REGION

      - name: Log in to Amazon ECR
        run: |
          aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin ${{ secrets.ECR_REPOSITORY }}

      - name: Build Docker image
        run: docker build -t my-docker-app .

      - name: Tag Docker image
        run: docker tag my-docker-app:latest ${{ secrets.ECR_REPOSITORY }}:latest

      - name: Push Docker image to Amazon ECR
        run: docker push ${{ secrets.ECR_REPOSITORY }}:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Set up AWS credentials for session
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }}
        run: |
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
          aws configure set aws_session_token $AWS_SESSION_TOKEN
          aws configure set region $AWS_DEFAULT_REGION

      - name: Update ECS service
        run: |
          aws ecs update-service --cluster ref-card-02 --service ref-card-02-dev  --task-definition ref-card-02-dev --network-configuration "awsvpcConfiguration={subnets=[subnet-0a3b3b8dc9c574421],securityGroups=[sg-0025a1fa3a6e2098b],assignPublicIp=ENABLED}"
