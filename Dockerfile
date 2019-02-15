FROM tozd/nginx-cron:ubuntu-xenial

ENV VIRTUAL_HOST chat.cloyne.org
ENV NODE_VERSION 8.11.4
ENV RC_VERSION latest

VOLUME /data/mongo
VOLUME /dump
VOLUME /var/log/rocketchat

# RUN apt-get update -q -q && \
#  apt-get install rsyslog locales --no-install-recommends --yes && \
#  apt-get install openssh-server --yes && \
#  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
#  dpkg-reconfigure locales
#
# gpg: key 4FD08014: public key "Rocket.Chat Buildmaster <buildmaster@rocket.chat>" imported
RUN gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0E163286C20D07B9787EBE9FD7F9D0414FD08104

COPY ./etc /etc

## Install necessary dependency packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 && \
 echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
 apt-get install apt-transport-https && \
 apt-get update && \
 apt-get install curl build-essential mongodb-org --no-install-recommends -y && \
 curl -sL curl -sL https://deb.nodesource.com/setup_8.x | sudo bash - && \
 apt-get install -y nodejs graphicsmagick && \
 npm install -g inherits n && \
 n $NODE_VERSION && \
 set -x && \
 curl -SLf "https://releases.rocket.chat/${RC_VERSION}/download" -o rocket.chat.tgz && \
 curl -SLf "https://releases.rocket.chat/${RC_VERSION}/asc" -o rocket.chat.tgz.asc && \
 gpg --verify rocket.chat.tgz.asc && \
 mkdir -p /Rocket.Chat && \
 tar -zxf rocket.chat.tgz -C /Rocket.Chat && \
 rm rocket.chat.tgz rocket.chat.tgz.asc && \
 npm cache clear --force

# Configure the Rocket.Chat service
RUN set -x && \
 groupadd -g 99999 -r rocketchat && \
 useradd -u 99999 -r -g rocketchat rocketchat && \
 cd /Rocket.Chat/bundle/programs/server && \
 npm install && \
 npm cache clear --force && \
 sed -i 's/log\/nullmailer/log\/rocketchat\/nullmailer/' /etc/service/nullmailer/log/run && \
 chown -R rocketchat:rocketchat /Rocket.Chat


USER rocketchat

VOLUME /Rocket.Chat/uploads

WORKDIR /Rocket.Chat/bundle

# needs a mongoinstance - defaults to container linking with alias 'mongo'
ENV DEPLOLY_METHOD=docker \
NODE_ENV=production \
MONGO_URL=mongodb://mongo:27017/rocketchat \
HOME=/tmp \
PORT=3000 \
ROOT_URL=${VIRTUAL_HOST}:3000 \
Accounts_AvatarStorePath=/Rocket.Chat/uploads

EXPOSE 3000
