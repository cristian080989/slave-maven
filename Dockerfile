FROM ubuntu:18.04

LABEL maintainer="Bibin Wilson <bibinwilsonn@gmail.com>"

ENV KOPS_VERSION=1.13
# https://kubernetes.io/docs/tasks/kubectl/install/
# latest stable kubectl: curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
ENV KUBECTL_VERSION=v1.13
ENV TERRAFORM_VERSION=0.13
ENV TERRAGRUNT_VERSION=0.35.18
ENV HELM_VERSION=v3.7.2
ENV PACKER_VERSION=1.7.7
#RUN apk add --update \
#    python \
#   python-dev \
#    py-pip \
#    build-base \
#    ansible \
#  && pip install virtualenv docker-compose awscli

RUN apk --no-cache update \
&& apk --no-cache add ca-certificates python py-pip py-setuptools groff less \
&& apk --no-cache add --virtual build-dependencies curl \
&& pip --no-cache-dir install awscli \
&& curl -LO --silent --show-error https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
&& mv kops-linux-amd64 /usr/local/bin/kops \
&& curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
&& mv kubectl /usr/local/bin/kubectl \
&& curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& mv terraform /usr/local/bin/terraform \
&& curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
&& chmod +x /usr/local/bin/terragrunt \
&& curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip packer_${PACKER_VERSION}_linux_amd64.zip \
&& mv packer /usr/local/bin/packer \
&& curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
&& tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
&& mv linux-amd64/helm /usr/local/bin/helm \
&& chmod +x /usr/local/bin/kops /usr/local/bin/kubectl /usr/local/bin/terraform /usr/local/bin/helm \
&& apk del --purge build-dependencies \
&& rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz \
&& rm -rf /var/cache/apk/*

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 8 (latest stable edition at 2019-04-01)
    apt-get install -qy openjdk-8-jdk && \
# Install maven
    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    adduser --quiet jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
