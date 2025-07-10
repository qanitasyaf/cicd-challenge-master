# Assuming your Dockerfile starts with this base image
FROM docker.io/jenkins/jenkins:lts

# Switch to root user to perform system-level installations
# The jenkins/jenkins:lts image often switches to 'jenkins' user,
# so we explicitly become root for apt operations.
USER root

# Step 1: Update apt and install necessary packages including curl and gnupg
# The previous log showed 'cur' which might have been truncated, ensuring 'curl' and 'gnupg' are fully listed.
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    rm -rf /var/lib/apt/lists/*

# Step 2: Add HashiCorp GPG key and repository, then install Terraform
# Added --batch to the gpg --dearmor command to prevent TTY interaction issues.
# RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor --batch -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
#     apt-get update && \
#     apt-get install -y terraform

# Switch back to the 'jenkins' user if subsequent operations or the container's
# entrypoint expect to run as this user. This is good practice for security.
USER jenkins

# ... (rest of your Dockerfile, if any, for installing other tools or setting up your application)


