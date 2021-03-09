# Demo REST API using Servant and Squeal

## Summary

This is a project I quickly put together to demonstrate my ability to create web
services and to quickly jump in to new Haskell libraries.

I took a relatively small sample database from
https://www.postgresqltutorial.com/postgresql-sample-database that contains a
model for managing DVD rentals (yeah, it's dated) and created a few endpoints
exposing part of this database as JSON:

* `GET /films` will retrieve a JSON array of every film in the database
* `GET /films?title=<title>` will retrieve a JSON array of every film matching the title given in the query parameter
* `GET /films/:id` will retrieve a JSON object for a film with a specific ID

Other verbs and resources were elided in the interest of time.

## Building

This project has a dependency on `docker-compose`.

To build, simply run

```
docker-compose build
```

within the project directory.


## Usage

To start the database and server, run

```
docker-compose up -d
```

This will create a server listening on port 8080. To test it out:

```
curl "localhost:8080/films"
```

You should see the list of films available in the database printed out in your
terminal.

## Other Notes

This project does not make use of any secrets management, and has the postgres
credentials hardcoded into the webserver code. This is obviously not acceptable
in a production environment and I would normally take proper care with secrets,
but doing it this way was the fastest way I could get this project up and
running.
