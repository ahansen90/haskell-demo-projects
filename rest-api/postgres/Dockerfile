FROM postgres:latest
ENV POSTGRES_DB=dvdrental
ENV POSTGRES_PASSWORD=password
COPY dvdrental.tar /dvdrental.tar
COPY seed.sh /docker-entrypoint-initdb.d
