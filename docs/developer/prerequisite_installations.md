### Prerequisites

Before building and pushing a Docker image, ensure the following prerequisites are complete:

#### 1. Install Homebrew
Homebrew is a package manager for macOS, which is necessary to install Docker or other dependencies. Follow these steps to check and install Homebrew:
1. Check if Homebrew is installed by running:
   ```bash
   brew --version
   ```
   **Expected Output**:
   ```
   Homebrew X.X.X
   ```
2. If Homebrew is not installed, install it using the following command:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Verify the installation:
   ```bash
   brew --version
   ```
   **Expected Output**:
   ```
   Homebrew X.X.X
   ```

#### 2. Install Docker
Docker is required to build and push images. You can install Docker Desktop for macOS by following these steps:
1. Download Docker Desktop for macOS 
   1. Option 1 - download with HomeBrew
        ```bash
      brew install docker
        ```
   2. Option 2 - download from Website
      1. Vist the [Docker website](https://www.docker.com/products/docker-desktop).
      2. Run the installer and follow the instructions to complete the installation.
3. Verify the installation by running the following command in the terminal:
   ```bash
   docker --version
   ```
   **Expected Output**:
   ```
   Docker version XX.XX.XX, build XXXXXXXX
   ```

#### 3. Install AWS CLI
The AWS Command Line Interface (CLI) is required to log into AWS and interact with AWS services.

1. Run the command to install AWS CLI using Homebrew:
   ```bash
   brew install awscli
   ```
2. Verify the installation:
   ```bash
   aws --version
   ```
   **Expected Output**:
   ```
   aws-cli/2.X.X Python/X.X.X Darwin/X.X.X source
   ```

#### 3. Install AWS CLI
The AWS Command Line Interface (CLI) is required to log into AWS and interact with AWS services.

1. Run the command to install AWS CLI using Homebrew:
   ```bash
   brew install awscli
   ```
2. Verify the installation:
   ```bash
   aws --version
   ```
   **Expected Output**:
   ```
   aws-cli/2.X.X Python/X.X.X Darwin/X.X.X source
   ```


#### 4. Install Terraform CLI
The Terraform Command Line Interface (CLI) is required to perform Terraform actions.

1. Run the command to install Terraform CLI using Homebrew:
   ```bash
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```
2. Verify the installation:
   ```bash
   terraform -version
   ```
   **Expected Output**:
   ```plaintext
   Terraform v1.10.4
    ```


#### 5. Install Confluent CLI
The Confluent Command Line Interface (CLI) is required to log into Confluent and interact with Confluent services.

1. Run the command to install Confluent CLI using Homebrew:
   ```bash
   brew install confluentinc/tap/cli
   ```
2. Verify the installation:
   ```bash
   confluent version
   ```
   **Expected Output**:
   ```plaintext
   confluent - Confluent CLI
   
   Version:     v4.13.0
   Git Ref:     d438a667
   Build Date:  2024-11-22T22:40:41Z
   Go Version:  go1.22.7 (darwin/arm64)
   Development: false
    ```

### 6. Install `kubectl`
Run the following command to install `kubectl` via Homebrew:
   ```bash
   brew install kubectl
   ```

**Expected Output:**
- Output confirming `kubectl` was installed successfully.

Check the installed version of `kubectl` to confirm it is correctly installed.

   ```bash
   kubectl version --client
   ```

**Expected Output:**
- Output similar to:
  ```
  Client Version: version.Info{Major:"1", Minor:"X", GitVersion:"v1.X.X", ...
  ```
  Replace `1.X.X` with the latest version.

## 7. Install JQ

   ```bash
   brew install jq
   ```

   ```bash
   jq --version
   ```

## 8. Install Helm

#### 8. Install Helm

Helm is a package manager for Kubernetes, widely used to manage Kubernetes charts.

1. Run the command to install Helm using Homebrew:
   ```bash
   brew install helm
   ```

2. Verify the installation:
   ```bash
   helm version
   ```

**Expected Output:**

- A response similar to:
  ```plaintext
  version.BuildInfo{Version:"v3.X.X", GitCommit:"abcdef123456", GitTreeState:"clean", GoVersion:"go1.X.X"}
  ```

Replace `v3.X.X` with the latest version of Helm.

