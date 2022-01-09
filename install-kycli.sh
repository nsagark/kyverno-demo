#!/usr/bin/bash

apt install make

wget https://go.dev/dl/go1.17.6.linux-amd64.tar.gz

rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz >/dev/null 2>&1

export PATH=$PATH:/usr/local/go/bin

go version

git clone https://github.com/kyverno/kyverno

cd kyverno

make cli

mv ./cmd/cli/kubectl-kyverno/kyverno /usr/local/bin/kyverno
echo
echo "Printing kyverno version: "
kyverno version
