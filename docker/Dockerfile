### Webapp build
FROM node:16.3.0@sha256:ca6daf1543242acb0ca59ff425509eab7defb9452f6ae07c156893db06c7a9a4 as nodebuild

WORKDIR /webapp
ADD webapp/ /webapp

RUN CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm install --no-optional && \
    npm run pack

### Go build
# Mantemos o Bookworm que você já configurou corretamente
FROM golang:1.21.3-bookworm AS gobuild

WORKDIR /go/src/focalboard
ADD . /go/src/focalboard
RUN apt-get update && apt-get install -y gcc libc6-dev make git

RUN EXCLUDE_PLUGIN=true EXCLUDE_SERVER=true EXCLUDE_ENTERPRISE=true make server-docker os=linux arch=amd64 VERBOSE=1

## Final image
# O ERRO ESTAVA AQUI: Mudamos de buster-slim para bookworm-slim e REMOVEMOS o sha256
FROM debian:bookworm-slim

RUN mkdir -p /opt/focalboard/data/files
RUN chown -R nobody:nogroup /opt/focalboard

WORKDIR /opt/focalboard

COPY --from=nodebuild --chown=nobody:nogroup /webapp/pack pack/
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/bin/docker/focalboard-server bin/
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/LICENSE.txt LICENSE.txt
# Ajuste de segurança: Garantir que o config existe no destino
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/docker/server_config.json config.json

USER nobody

# Porta padrão do Focalboard
EXPOSE 8000/tcp

VOLUME /opt/focalboard/data

CMD ["/opt/focalboard/bin/focalboard-server"]
