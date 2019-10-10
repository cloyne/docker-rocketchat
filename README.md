# To start after unexpected reboot:

1. Verify that the NODE_VERSION environment variable is up to date with
   [rocketchat/base](https://hub.docker.com/r/rocketchat/base/dockerfile)
2. Fix the SSL symlinks in `nginx-proxy`:
    ```
    docker exec -ti nginx-proxy /bin/bash --login
    cd /ssl
    ln -s letsencrypt/live/chat.cloyne.org/fullchain.pem chat.cloyne.org.crt
    ln -s letsencrypt/live/chat.cloyne.org/privkey.pem chat.cloyne.org.key
    exit
    ```
3. Currently /etc/service/rocketchat/run doesn't start appropriately and has to
   be started manually from within the container. It takes a minute to load.
   ```
    docker exec --user root -ti rocketchat /bin/bash --login
    /etc/service/rocketchat/run
   ```
4. If you get `502 bad gateway`, check `docker network inspect server3.cloyne.org` and confirm the internal IP address of the `rocketchat` container. Go back into `nginx-proxy` and make sure the upstream in `/etc/nginx/sites-enabled/zzz-virtual.conf` matches, then restart nginx with `sv restart nginx`.

# To start from scratch for development
First, run the [mongo](github.com/cloyne/docker-mongodb) container. From inside
the mongo container, run `mongo` to open the mongodb shell, then run
`rs.initiate()`.
Then exit the mongo container and start the rocketchat service as in step 3
above.
