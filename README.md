# To start after unexpected reboot:

1. Verify that the NODE_VERSION environment variable is up to date with
   [rocketchat/base](https://hub.docker.com/r/rocketchat/base/dockerfile)
2. Fix the SSL symlinks in `nginx-proxy`:
    ```bash
    docker exec -ti nginx-proxy /bin/bash --login
    cd /ssl
    ln -s letsencrypt/live/chat.cloyne.org/fullchain.pem chat.cloyne.org.crt
    ln -s letsencrypt/live/chat.cloyne.org/privkey.pem chat.cloyne.org.key
    exit
    ```
3. Currently /etc/service/rocketchat/run doesn't start appropriately and has to
   be started manually from within the container. It takes a minute to load.
   ```bash
    docker exec --user root -ti rocketchat /bin/bash --login
    /etc/service/rocketchat/run
   ```
4. If you get `502 bad gateway`, check `docker network inspect server3.cloyne.org` and confirm the internal IP address of the `rocketchat` container. Go back into `nginx-proxy` and make sure the upstream in `/etc/nginx/sites-enabled/zzz-virtual.conf` matches, then restart nginx with `sv restart nginx`.

# To start from scratch for development
First, run the [mongo](github.com/cloyne/docker-mongodb) container.

Then initiate the replica set within the mongo container:
```bash
docker exec --user root mongo mongo --eval "rs.initiate()"
```
Then start the rocketchat service as in step 3 above.

# To add users
First, do a csv import according to [these instructions](https://rocket.chat/docs/administrator-guides/import/csv/). 
Any new users created this way will start out deactivated. To activate them, you must log into the database:
```
docker exec --user root -ti mongo /bin/bash --login
root@mongo:/# mongo
rs01:PRIMARY> use rocketchat
rs01:PRIMARY> db.users.update({username: "NAME"}, {$set: {active: true}})
```
for adding a single user
