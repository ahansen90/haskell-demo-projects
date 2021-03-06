FROM haskell:8.10.2

RUN apt-get update
RUN apt-get install -y procps

RUN mkdir -p /app/user
WORKDIR /app/user
COPY stack.yaml *.cabal ./

RUN export PATH=$(stack path --local-bin):$PATH
RUN stack build --dependencies-only

COPY . /app/user
RUN stack install
