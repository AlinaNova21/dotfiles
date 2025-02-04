{pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      go
      go-swag
      openapi-generator-cli
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      grpc-gateway
    ];
    shellHook = ''
      export GOPATH=$HOME/go
      export PATH=$GOPATH/bin:$PATH
      source <(go env)
      export GOROOT
    '';
  }
