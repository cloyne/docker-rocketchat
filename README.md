To start after unexpected reboot:

1. Verify that the NODE_VERSION environment variable is up to date with
   [rocketchat/base](https://hub.docker.com/r/rocketchat/base/dockerfile)
2. Fix the SSL symlinks in `nginx-proxy`:
    docker exec -ti nginx-proxy /bin/bash --login
    cd /ssl
    ln -s letsencrypt/live/chat.cloyne.org/fullchain.pem chat.cloyne.org.crt
    ln -s letsencrypt/live/chat.cloyne.org/privkey.pem chat.cloyne.org.key
    exit
3. Currently /etc/service/rocketchat/run doesn't start appropriately and has to
   be started manually from within the container. It takes a minute to load.
    docker exec --user root -ti rocketchat /bin/bash --login
    /etc/service/rocketchat/run
