SHELL := /bin/bash

VERSION  = v2.61.0
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
			  /tmp/terraform-provider-aws
	cd /tmp/terraform-provider-aws &&\
		git reset --hard $(VERSION) &&\
		go install &&\
		cp $(GOBIN)/terraform-provider-aws ~/.terraform.d/plugins/terraform-provider-aws_$(VERSION)_x4

clean:
	rm -rf /tmp/terraform-provider-aws
	rm ~/.terraform.d/plugins/terraform-provider-aws_$(VERSION)_x4
	rm $(GOPATH)/bin/terraform-provider-aws