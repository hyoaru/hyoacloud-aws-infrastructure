deploy-core:
	./scripts/deploy-core.sh $(layer)

destroy-core:
	./scripts/destroy-core.sh $(layer)

deploy-space:
	./scripts/deploy-space.sh $(env) $(layer)

destroy-space:
	./scripts/destroy-space.sh $(env) $(layer)

