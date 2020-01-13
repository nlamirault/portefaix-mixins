# Copyright (C) 2019 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

APP = monitoring-mixins

VERSION = 0.3.0

SHELL = /bin/bash -o pipefail

DIR = $(shell pwd)

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
INFO_COLOR=\033[34;01m

MAKE_COLOR=\033[33;01m%-30s\033[0m

.DEFAULT_GOAL := help

OK=[✅]
KO=[❌]
WARN=[⚠️]

OUTPUT_DIRECTORY=mixins


.PHONY: help
help:
	@echo -e "$(OK_COLOR)==== $(APP) [$(VERSION)] ====$(NO_COLOR)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(MAKE_COLOR) : %s\n", $$1, $$2}'

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Environment variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

check-%:
	@if $$(hash $* 2> /dev/null); then \
		echo -e "$(OK_COLOR)$(OK)$(NO_COLOR) $*"; \
	else \
		echo -e "$(ERROR_COLOR)$(KO)$(NO_COLOR) $*"; \
	fi

.PHONY: check
check: check-jb check-jsonnet ## Check requirements

.PHONY: clean
clean: ## Clean environment
	@rm -fr $(OUTPUT_DIRECTORY) $(APP)*.tar.gz


# ====================================
# M I X I N S
# ====================================


.PHONY: deps
deps: ## Retrieve dependencies
	@go get github.com/google/go-jsonnet/cmd/jsonnet
	@go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	@go get github.com/brancz/gojsontoyaml

generate-%:
	@echo -e "$(OK_COLOR)[$(APP)] Generate mixin $*$(NO_COLOR)"
	@./monitoring-mixins.sh $* $(OUTPUT_DIRECTORY)

.PHONY: kubernetes-mixin
kubernetes-mixin: generate-kubernetes-mixin ## Generate mixin for Kubernetes

.PHONY: node-mixin
node-mixin: generate-node-mixin ## Generate mixin for Node Exporter

.PHONY: prometheus-mixin
prometheus-mixin: generate-prometheus-mixin ## Generate mixin for Prometheus

.PHONY: etcd-mixin
etcd-mixin: generate-etcd-mixin ## Generate mixin for Etcd

.PHONY: elasticsearch-mixin
elasticsearch-mixin: generate-elasticsearch-mixin ## Generate mixin for Elasticsearch

.PHONY: loki-mixin
loki-mixin: generate-loki-mixin ## Generate mixin for Loki

.PHONY: kube-state-metrics-mixin
kube-state-metrics-mixin: generate-kube-state-metrics-mixin ## Generate mixin for KubeStateMetrics

.PHONY: thanos-mixin
thanos-mixin: generate-thanos-mixin ## Generate mixin for Thanos

.PHONY: mixins
mixins: kubernetes-mixin node-mixin prometheus-mixin etcd-mixin elasticsearch-mixin loki-mixin thanos-mixin # kube-state-metrics-mixin ## Generate all mixins

.PHONY: package
package: ## Generate an archive with mixins
	@echo -e "$(OK_COLOR)[$(APP)] Create mixins archive$(NO_COLOR)"
	tar zcvf $(APP)-$(VERSION).tar.gz $(OUTPUT_DIRECTORY)
