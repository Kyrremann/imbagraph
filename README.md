Imbagraph
=========

> Not the stats you want, but the stats you need


## Development

You need a Ruby environment running `2.5.0`. For testing, we recommend using a Postgres-database, which can be easily spin up with Docker.

```bash
# Install Ruby dependencies
bundler install
# Start Postgres container
docker run --name postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=imbagraph -p 5432:5432 -d postgres:latest
# Add data
ruby feed_pg.rb kyrremann untappd-05-02-2018.json
# Start server
ruby webapp.rb
# Go to you localhost:4567 in you browser
```

If you alread have a postgres-instance running in Docker, you can add a new database with the following commando:
```bash
docker exec -it postgres psql -U postgres -c "CREATE DATABASE imbagraph"
```

Note: You need to restart the app to change Ruby-files, but you can change Haml-files on the fly.
