# Building and Pushing a Docker Image to a Docker Repository

This guide explains the process of building a Docker image and pushing it to a Docker repository. 

---

### Prerequisites
 - [Install all required software](prerequisite_installations.md)\
 - [Set relevant environment variables](get_and_set_environment_variables.md) 

---

### Building and Pushing the Docker Image

Once prerequisites are satisfied, follow these steps to build and push the Docker image:

#### 1. Start the Docker daemon
- Open the Application
    ```bash
   open /Applications/Docker.app
   ```
- Validate the Application is open
     ```bash
  docker info
  ```
- **Expected Output**
  ```
  ~/PycharmProjects/OracleDBConnector/Docs/Developer ❯ docker info                                                                                                                                     Py OracleDBConnector 16:42:21
  Client: Docker Engine - Community
  Version:    27.5.0
  Context:    desktop-linux
  Debug Mode: false
  ...
  ```
- Ensure buildx is configured
  ```bash
  docker buildx version
  ```
- Create new buildx builder
  ```bash
  docker buildx create --name multiarch-builder --use
  ```
- Start the builder
  ```bash
  docker buildx inspect --bootstrap
  ```

#### 2. Build the docker image
- Build the Docker image

   ```bash
   docker buildx build --platform linux/amd64 -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --load -f ./../../webapp/Dockerfile ./../../webapp
   ```
- **Expected Output**
  ```
  [+] Building 1.2s (11/11) FINISHED                                                                                                                                                                            docker:desktop-linux
  => [internal] load build definition from Dockerfile                                                                                                                                                                          0.0s
  => => transferring dockerfile: 507B                                                                                                                                                                                          0.0s
  => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                                                                           1.1s
  => [internal] load .dockerignore                                                                                                                                                                                             0.0s
  => => transferring context: 2B                                                                                                                                                                                               0.0s
  => [1/6] FROM docker.io/library/python:3.12-slim@sha256:123be5684f39d8476e64f47a5fddf38f5e9d839baff5c023c815ae5bdfae0df7                                                                                                     0.0s
  => => resolve docker.io/library/python:3.12-slim@sha256:123be5684f39d8476e64f47a5fddf38f5e9d839baff5c023c815ae5bdfae0df7                                                                                                     0.0s
  => [internal] load build context                                                                                                                                                                                             0.0s
  => => transferring context: 5.55kB                                                                                                                                                                                           0.0s
  => CACHED [2/6] RUN useradd -u 1001 -m appuser                                                                                                                                                                               0.0s
  => CACHED [3/6] WORKDIR /opt/fraud_detection                                                                                                                                                                                 0.0s
  => CACHED [4/6] ADD fraud_detection /opt/fraud_detection                                                                                                                                                                     0.0s
  => CACHED [5/6] RUN pip install --no-cache-dir -r /opt/fraud_detection/requirements.txt                                                                                                                                      0.0s
  => CACHED [6/6] RUN python /opt/fraud_detection/manage.py collectstatic --no-input                                                                                                                                           0.0s
  => exporting to image                                                                                                                                                                                                        0.0s
  => => exporting layers                                                                                                                                                                                                       0.0s
  => => exporting manifest sha256:88703da9e058c8cad6a9d930f33ac477468f133b8a1fb6a5398aa63e9901b4b4                                                                                                                             0.0s
  => => exporting config sha256:f78d1dc18c626e24fcfebb956dab6678299deeb613fef17c31db6144a4997c1f                                                                                                                               0.0s
  => => exporting attestation manifest sha256:63b6d25788087a1bd9015179791a3f9cdf2c5c2d426c89204291675b4c1aa27d                                                                                                                 0.0s
  => => exporting manifest list sha256:054c05314a55084f85bdf35c2b5c3cc534bff6a1a29bdbfd57e5c55ff9305a4a                                                                                                                        0.0s
  => => naming to docker.io/library/fraud-demo-webapp:latest                                                                                                                                                                   0.0s
  => => unpacking to docker.io/library/fraud-demo-webapp:latest      
  ```
- Inspect the docker architecture to ensure it is amd64
```bash
docker inspect ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} | grep Architecture
```

#### 3. Tag the Docker Image Locally
- After building the image, tag it with the full repository URL. This is required to push the image to the repository.
  - Private 
    ```bash
    docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${PRIVATE_DOCKER_IMAGE_URL}
     ```
  - Public
    ```bash
      docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${PUBLIC_DOCKER_IMAGE_URL}
    ```

## Commoon issue

Cant pull base image

How to fix 

```bash
rm  ~/.docker/config.json 
```