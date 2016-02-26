FROM python:2-alpine

RUN apk add --update build-base git unzip

RUN git clone https://github.com/CiscoCloud/mantl /mantl

RUN pip install --upgrade pip \
	&& pip install -r /mantl/requirements.txt

VOLUME /local
ENV TERRAFORM_VERSION=0.6.10 TERRAFORM_STATE_ROOT=/local

RUN mkdir -p /tmp/terraform/ && \
    cd /tmp/terraform/ && \
    curl -SLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    cd /usr/local/bin/ && \
    unzip /tmp/terraform/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -rf /tmp/terraform/

WORKDIR /local
