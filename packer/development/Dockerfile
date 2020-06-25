# Docker configuration to start an ansible worker
# Mount your ansible config at /etc/ansible and playbooks at /playbooks
# Sample commands:
# docker build -t ansibleworker:1.0
# docker run -ti --rm -v $(pwd)/../ansible:/etc/ansible -v $(pwd)/../playbooks:/playbooks ansibleworker:1.0

FROM alpine:latest

# Install dependencies
RUN apk update && \
      apk upgrade &&  \
      apk add --no-cache --update ansible python3 py-pip py3-setuptools bash libffi-dev py-netaddr openssh sshpass zip
# Initialize
RUN mkdir -p /etc/ansible
RUN mkdir -p /playbooks
WORKDIR /playbooks
# RUN
CMD ["/bin/sh"]
