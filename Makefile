PROTO_DIR := proto
PKG_DIR   := paxos

.PHONY: gen gen-go test build tidy

gen: gen-go

gen-go:
	protoc \
		--proto_path=$(PROTO_DIR) \
		--go_out=$(PKG_DIR) --go_opt=paths=source_relative \
		--go-grpc_out=$(PKG_DIR) --go-grpc_opt=paths=source_relative \
		$(PROTO_DIR)/paxos.proto

test:
	go test -race -v ./...

build:
	go build ./...

tidy:
	go mod tidy
