SHELL := /bin/bash

export
.ONESHELL:

init:
	set -euo pipefail
	source scripts/env.sh
	terraform -chdir=terraform init

plan:
	set -euo pipefail
	source scripts/env.sh
	terraform -chdir=terraform plan

apply:
	set -euo pipefail
	source scripts/env.sh
	terraform -chdir=terraform apply -auto-approve

destroy:
	set -euo pipefail
	source scripts/env.sh
	terraform -chdir=terraform destroy -auto-approve

output:
	set -euo pipefail
	source scripts/env.sh
	terraform -chdir=terraform output

