#!/usr/bin/env bash
# Generate a plan for an environment and report the size of the resulting
# machine-readable plan (the artifact policy engines like OPA/Sentinel consume).
set -euo pipefail

ENV="${1:-prod}"
ENV_DIR="$(cd "$(dirname "$0")/.." && pwd)/environments/${ENV}"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "Unknown environment: ${ENV}" >&2
  echo "Available: $(ls "$(dirname "${ENV_DIR}")")" >&2
  exit 1
fi

cd "${ENV_DIR}"

echo "==> init (${ENV})"
terraform init -input=false >/dev/null

echo "==> plan (${ENV})"
terraform plan -input=false -out=tfplan.bin >/dev/null

echo "==> rendering plan.json"
terraform show -json tfplan.bin > plan.json

bytes=$(wc -c < plan.json)
mb=$(python3 -c "print(f'{${bytes}/1024/1024:.2f}')")
count=$(python3 -c "import json;print(len(json.load(open('plan.json'))['resource_changes']))")

echo "-----------------------------------------"
echo "environment      : ${ENV}"
echo "plan.json size   : ${bytes} bytes (${mb} MB)"
echo "resource changes : ${count}"
echo "-----------------------------------------"
