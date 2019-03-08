FROM golang:alpine AS build-env
WORKDIR /go/src
COPY . /go/src/test-app
RUN cd /go/src/test-app && go build .
#go build command creates a linux binary that can run without any go tooling.

FROM alpine
#Alpine is one of the lightest linux containers out there, only a few MB
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk*
WORKDIR /app
COPY --from=build-env /go/src/test-app/test-app /app
COPY --from=build-env /go/src/test-app/templates /app/templates
COPY --from=build-env /go/src/test-app/static /app/static
#Here we copy the binary from the first image (build-env) to the new alpine container as well as the html and css

EXPOSE 8080
ENTRYPOINT [ "./test-app" ]