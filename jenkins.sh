#!/bin/bash

set -ex  # Exit immediately if a command exits with a non-zero status and print commands

echo "Starting installation script..."

# System information
echo "System Information:"
uname -a
cat /etc/os-release

# Update the system
sudo yum update -y

# Install wget
echo "Installing wget..."
sudo yum install wget -y

# Install Java 11
echo "Installing Java 11..."
sudo amazon-linux-extras install java-openjdk11 -y
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-11.0.*/bin/java

# Check Java version
java -version

# Import Jenkins GPG key
echo "Importing Jenkins GPG key..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo yum install jenkins -y

# Configure Jenkins Java home
echo "Configuring Jenkins Java home..."
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
echo "[Service]
Environment=\"JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Add verbose logging for Jenkins
echo "JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York\"" | sudo tee -a /etc/sysconfig/jenkins
echo "JENKINS_LOG=/var/log/jenkins/jenkins.log" | sudo tee -a /etc/sysconfig/jenkins
sudo mkdir -p /var/log/jenkins
sudo chown jenkins:jenkins /var/log/jenkins

# Ensure correct permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins

# Reload systemd
sudo systemctl daemon-reload

# Start Jenkins
echo "Starting Jenkins service..."
sudo systemctl start jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
for i in {1..60}; do
    if sudo systemctl is-active --quiet jenkins; then
        echo "Jenkins started successfully."
        break
    fi
    if [ $i -eq 60 ]; then
        echo "Jenkins failed to start within the expected time."
        sudo systemctl status jenkins
        exit 1
    fi
    echo "Waiting for Jenkins to start... (Attempt $i/60)"
    sleep 10
done

# If Jenkins is running, retrieve the initial admin password
if sudo systemctl is-active --quiet jenkins; then
    echo "Jenkins is running. Retrieving initial admin password..."
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "Jenkins installation completed successfully. Access Jenkins at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
    echo "Jenkins installation completed successfully."
else
    echo "Jenkins is not running. Installation failed."
    exit 1
fi

# Install Git
echo "Installing Git..."
sudo yum install git -y

# Install latest Terraform
echo "Installing latest Terraform..."
TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
sudo wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
sudo rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Install the latest Docker
echo "Installing Docker..."

# Remove older versions of Docker if they exist
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine -y

# Set up the Docker repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE (Community Edition)
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add the current user to the Docker group to run Docker without sudo
sudo usermod -aG docker $USER

# Enable Docker Compose V2 (part of Docker CLI plugin)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker installation
docker --version
docker-compose --version

echo "Docker installation completed."


# Install latest Grafana
echo "Installing latest Grafana..."
sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-latest-1.x86_64.rpm
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Install latest Prometheus
echo "Installing latest Prometheus..."
PROMETHEUS_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
sudo wget "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
sudo tar -xvzf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64" /opt/prometheus
sudo rm "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

# Install latest kubectl
echo "Installing latest kubectl..."
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo rm kubectl

# Install Python 3 and pip3
echo "Installing Python 3 and pip3..."
sudo yum install python3 python3-pip -y

# Install latest Minikube
echo "Installing latest Minikube..."
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -ivh minikube-latest.x86_64.rpm
sudo rm minikube-latest.x86_64.rpm

echo "Installation completed."
