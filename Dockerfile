FROM oraclelinux:7-slim as builder
ARG NPM_REGISTRY
ARG HTTP_PROXY
ARG COMPARTMENT_ID
WORKDIR '/app'
 
COPY package.json .
# optional line below
COPY ol7_developer_nodejs8.repo /etc/yum.repos.d/
RUN echo proxy=${HTTP_PROXY} >>/etc/yum.conf
 
RUN yum -y update && \
    rm -rf /var/cache/yum && \
    yum -y install nodejs
 
RUN  yum -y install python3
 
RUN npm config set registry ${NPM_REGISTRY}
RUN npm install
COPY . .
RUN npm run build
 
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl \
        && chmod +x ./kubectl \
        && rm -rf /tmp/*
 
ENV PATH="/app:/bin:/root/bin:${PATH}"
ENV KUBECONFIG="/root/.kube/oci_config"
ENV LC_ALL="en_US.utf8"
ENV C ${COMPARTMENT_ID}
 
RUN curl -LO https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh \
        && chmod +x ./install.sh  \
        && ./install.sh --accept-all-defaults
 
EXPOSE 5000
ENTRYPOINT ["/bin/bash"]
CMD []