GO_VERSION=1.22.0

tools:
	go install -C internal/tools \
		github.com/fdaines/spm-go \
		github.com/golangci/golangci-lint/cmd/golangci-lint \
		github.com/jackc/tern/v2 \
		github.com/maxbrunsfeld/counterfeiter/v6 \
		github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen \
		github.com/sqlc-dev/sqlc/cmd/sqlc \
		goa.design/model/cmd/mdl \
		goa.design/model/cmd/stz \
		golang.org/x/vuln/cmd/govulncheck

install:
	go install golang.org/dl/go${GO_VERSION}@latest
	go${GO_VERSION} download
	mkdir -p bin
	ln -sf `go env GOPATH`/bin/go${GO_VERSION} bin/go

lint: tools generate golangci govulncheck vet dirty

dirty:
	@status=$$(git status --untracked-files=no --porcelain); \
	if [ ! -z "$${status}" ]; \
	then \
		echo "ERROR: Working directory contains modified files"; \
		git status --untracked-files=no --porcelain; \
		exit 1; \
	fi

generate:
	go generate ./...

golangci:
	golangci-lint run ./...

govulncheck:
	govulncheck ./...

vet:
	go vet ./...

test:
	go test -shuffle=on -race -coverprofile=coverage.txt -covermode=atomic $$(go list ./... | grep -v /cmd/)
