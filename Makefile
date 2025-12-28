deploy-core:
	./scripts/deploy-core.sh $(group) $(layer)

destroy-core:
	./scripts/destroy-core.sh $(group) $(layer)

deploy-space:
	./scripts/deploy-space.sh $(env) $(group) $(layer)

destroy-space:
	./scripts/destroy-space.sh $(env) $(group) $(layer)

