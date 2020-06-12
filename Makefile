SHELL := /bin/bash

AWS_PROVIDER_VERSION   = v2.61.0
AWS_PROVIDER_FILE_NAME = terraform-provider-aws_$(AWS_PROVIDER_VERSION)_x4

GOEXE   ?= /usr/bin/go
GOPATH   = $(CURDIR)/.gopath
GOBIN    = $(GOPATH)/bin

.PHONY: deps clean


$(GOEXE):
	@echo "You need to install golang. Please do so first. https://golang.org/doc/install"
	@exit 1

deps: $(GOEXE)
	git clone --single-branch \
			  --branch amplify \
			  git@github.com:masterpointio/terraform-provider-aws.git \
			  ./tmp/terraform-provider-aws
	cd ./tmp/terraform-provider-aws && \
		go install && \
		cp $(GOBIN)/terraform-provider-aws ~/.terraform.d/plugins/$(AWS_PROVIDER_FILE_NAME)

clean:
	rm -rf ./tmp/
	rm ~/.terraform.d/plugins/$(AWS_PROVIDER_FILE_NAME)
	rm $(GOBIN)/terraform-provider-aws
