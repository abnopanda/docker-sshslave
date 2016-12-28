FROM openjdk:8-jdk-alpine

ENV HOME /home/jenkins
ENV JENKINS_REMOTE_VERSION 3.4
RUN adduser jenkins -h $HOME -D && \
  echo "jenkins:jenkins" | chpasswd

# setup SSH server
RUN apk --update --no-cache add openssh 
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin\ no/' /etc/ssh/sshd_config \
  && sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["/entrypoint.sh"]
COPY entrypoint.sh /
EXPOSE 22

RUN apk --update --no-cache add curl \
  && curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_REMOTE_VERSION}/remoting_${JENKINS_REMOTE_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar 

# ADD id_jenkins ${HOME}/.ssh/id_rsa
# ADD id_jenkins.pub ${HOME}/.ssh/id_rsa.pub
ADD id_jenkins.pub ${HOME}/.ssh/authorized_keys
RUN chown -R jenkins:jenkins ${HOME}/.ssh
RUN chmod 700 ${HOME}/.ssh

VOLUME /home/jenkins
WORKDIR /home/jenkins

RUN apk --update --no-cache add git rsync

# Create known host: Add github (or your git server) fingerprint to known hosts
# RUN touch ${HOME}/.ssh/known_hosts \
#  && ssh-keyscan -t rsa github.com >> ${HOME}/.ssh/known_hosts \
#  && ssh-keyscan -t rsa bitbucket.org >> ${HOME}/.ssh/known_hosts

# Download and install hugo
ENV HUGO_VERSION 0.18

RUN curl -LO https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  mv hugo*/hugo* /usr/bin/hugo && \
  apk del curl ca-certificates 


