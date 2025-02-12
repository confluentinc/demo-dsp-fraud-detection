# Pushing a Docker Image to a Public Docker Repository

This guide explains the process of building a Docker image and pushing it to a Public Docker repository. 

---

### Prerequisites
 - [Install all required software](prerequisite_installations.md)\
 - [Set relevant environment variables](get_and_set_environment_variables.md) 
 - [Build local Docker Image](docker_build_and_tag)

---


#### 1. Push the Docker Image Repository to the Remote
- To access your Docker repository on AWS (e.g., Amazon Elastic Container Registry - ECR), authenticate using AWS CLI:
   ```bash
   aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${PUBLIC_DOCKER_HOST_URL}
   ```
   

- **Expected Output**
   ```
   Login Succeeded
   ```

#### 4. Push the tagged Docker image to the remote Docker repository:
- Push the docker image to the remote
   ```bash
   docker push ${PUBLIC_DOCKER_IMAGE_URL}
   ```


#### 4. Logout when finished
- Logout of docker
    ```bash
   docker logout
   ```
   
#### 5. Test no-auth pull
- Pull the dockerfile
    ```bash
    docker pull public.ecr.aws/v3a9u0p7/demo/fraud-webapp:latest
    ```
  
#### 6. Test remote architecture of Dockerfile
- Test remote docker manifest architecture    
    ```bash
    docker inspect public.ecr.aws/v3a9u0p7/demo/fraud-webapp:latest | grep Architecture
    ```
---

### Common Errors and Troubleshooting
1. **Docker login authentication error**:
   - Ensure you correctly ran the AWS ECR login command to authenticate:
     ```bash
     aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${PUBLIC_DOCKER_HOST_URL}
     ```
   - [Verify your AWS credentials are set correctly](get_and_set_environment_variables.md)
     ```bash
     aws configure
     ```

2. **"Cannot connect to the Docker daemon" error**:
   - Ensure Docker Desktop is running on your machine and that you have sufficient permissions to run Docker commands.

3. **Image push denied**:
   - Check the permissions of your AWS IAM user or role associated with the ECR repository.

4. **Tag not found during push**:
   - Double-check that the image was correctly tagged as shown in the **Tag the Docker Image** section above.

---

