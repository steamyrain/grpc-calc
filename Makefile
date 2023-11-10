BIN_DIR = bin
PROTO_DIR = proto
CLIENT_DIR = client
SERVER_DIR = server

projects := cmd

CHECK_DIR_CMD = $(shell test -d $@ || (echo "this directory doesn't exist") && false)
PACKAGE = $(shell head -1 go.mod | awk '{print $$2}')

build: ${projects}

cmd: $@

$(projects):
	@${CHECK_DIR_CMD}
	protoc -I$@/${PROTO_DIR} --go_opt=module=${PACKAGE} --go_out=. \
	--go-grpc_opt=module=${PACKAGE} --go-grpc_out=. $@/${PROTO_DIR}/*.proto
	go build -o ${BIN_DIR}/$@/${SERVER_DIR} ./$@/${SERVER_DIR}
	go build -o ${BIN_DIR}/$@/${CLIENT_DIR} ./$@/${CLIENT_DIR}

clean:
	-rm ./cmd/${PROTO_DIR}/*.pb.go
	-rm ssl/*.crt
	-rm ssl/*.csr
	-rm ssl/*.key
	-rm ssl/*.pem
	-rm -r ${BIN_DIR}

bump: build
	go get -u ./..

.PHONY = build cmd clean bump
