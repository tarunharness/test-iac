# enterprise-terraform

An enterprise-style Terraform monorepo laid out the way large organizations
typically structure their infrastructure code: reusable modules, a composition
layer, and per-environment roots (`dev`, `staging`, `prod`) each with their own
backend, providers, and variables.

It is deliberately built to generate a **large plan (~60 MB of machine-readable
JSON in `prod`)** so it can be used to exercise plan-processing tooling — policy
engines (OPA/Conftest, Sentinel), plan diff viewers, CI artifact pipelines, cost
estimators, etc.

> **This variant has S3 buckets removed.** The `storage` module now provisions
> only NoSQL tables. Instance fleet counts were bumped to backfill the removed
> bucket resources so the `prod` plan still lands at ~60 MB.

> All resources use the `null`, `random`, and `local` providers, so `init`,
> `plan`, and `apply` run anywhere with **no cloud credentials** and touch **no
> real infrastructure**. The resource *shapes* (VPCs, subnets, instances, IAM
> policies, tables, alarms, topics, pipelines) mirror what a real AWS platform
> stack looks like.

## Repository layout

```
enterprise-terraform/
├── modules/                     # Reusable building blocks
│   ├── networking/              # VPCs, subnets, route tables, security groups
│   ├── compute/                 # Instance fleets, load balancers, autoscaling
│   ├── storage/                 # NoSQL tables (S3 buckets removed in this variant)
│   ├── iam/                     # Roles with least-privilege policy documents
│   ├── observability/           # Log groups, dashboards, alarm rules
│   ├── data_platform/           # Streaming topics + ETL pipelines
│   └── platform/                # Composition module wiring the above together
├── environments/
│   ├── dev/                     # Slim footprint
│   ├── staging/                 # Reduced mirror of prod
│   └── prod/                    # Full-scale (~60 MB plan)
├── global/
│   └── backend/                 # (placeholder for bootstrap: state bucket, locks)
├── scripts/plan-size.sh         # Generate a plan and report its size
├── .github/workflows/           # fmt / validate / plan CI
└── Makefile
```

## Usage

```bash
# Format and validate everything
make fmt
make validate ENV=prod

# Generate a plan and print the artifact sizes
make size ENV=prod        # ~60 MB plan.json, ~24k resources
make size ENV=staging     # medium
make size ENV=dev         # small

# Or use the helper script directly
./scripts/plan-size.sh prod
```

Per environment you can also run the raw workflow:

```bash
cd environments/prod
terraform init
terraform plan -out=tfplan.bin
terraform show -json tfplan.bin > plan.json   # <- the ~60 MB artifact
terraform show tfplan.bin        > plan.txt   # human-readable (~45 MB)
```

## What "plan size" means here

`terraform plan` produces a few different artifacts:

| Artifact                              | prod size | Notes                                  |
| ------------------------------------- | --------- | -------------------------------------- |
| `terraform show -json tfplan.bin`     | **~60 MB** | Machine-readable plan (OPA/Sentinel)   |
| `terraform show tfplan.bin` (text)    | ~45 MB    | Human-readable diff                    |
| `tfplan.bin` (saved plan)             | ~0.4 MB   | Compressed binary consumed by `apply`  |

The **JSON plan** is the artifact enterprises actually feed into policy-as-code
and CI pipelines, so that is what is tuned to ~60 MB.

## Tuning the size

Plan size scales almost entirely from `environments/prod/terraform.tfvars`.
The biggest lever is total instance count (`services[*].instance_count`), since
each instance carries a rich `user_data` + tag/config payload. Secondary levers:
`topic_count`, `pipeline_count`, `tables_per_domain`, `subnets_per_vpc`, and
`alerts_per_service`. (There is no `bucket_count` in this variant — S3 buckets
were removed.)

Roughly: **~8,000 resources ≈ 20 MB** of JSON (this repo's `prod` provisions
~24,000 resources for ~60 MB). Note Terraform's `range()` rejects >1024 values,
so no single count knob may exceed 1024 — add volume via more instances and
pipelines rather than one giant count. Scale proportionally to hit a different
target.

## Backends

Each environment has a `backend.tf` with a commented-out S3 + DynamoDB backend
showing the standard enterprise remote-state setup. It is disabled by default so
the repo initializes locally. Uncomment and `terraform init -reconfigure` to use
real remote state.
