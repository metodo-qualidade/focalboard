
FROM node:16.3.0 AS frontend
WORKDIR /webapp
COPY webapp .
RUN CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm install --no-optional && npm run pack

FROM golang:1.18.3 AS backend
WORKDIR /go/src/focalboard
COPY . .
COPY --from=frontend /webapp/pack webapp/pack

RUN apt-get update && apt-get install -y make gcc libc6-dev


RUN make server-linux


FROM debian:stretch-slim
WORKDIR /opt/focalboard


COPY --from=backend /go/src/focalboard/bin/linux/focalboard-server .
COPY --from=backend /go/src/focalboard/webapp/pack webapp/pack
COPY --from=backend /go/src/focalboard/config.json .

RUN mkdir -p /opt/focalboard/data && chmod 777 /opt/focalboard/data

EXPOSE 8000
CMD ["./focalboard-server"]
