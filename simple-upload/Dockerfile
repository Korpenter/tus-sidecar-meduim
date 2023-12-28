FROM golang:1.21-alpine as builder

WORKDIR /app

COPY . .

RUN go build -o myapp

FROM alpine:latest  

COPY --from=builder /app/ .

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
