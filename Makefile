
test:
	echo `pwd`
	docker run --rm \
		-e PLUGIN_TAG=latest \
		-e PLUGIN_REPO=index.boxlinker.com/boxlinker/blog \
		-e DRONE_COMMIT_SHA=d8dbe4d94f15fe89232e0402c6e8a0ddf21af3ab \
		-e PLUGIN_REGISTRY=index.boxlinker.com \
		-e PLUGIN_USERNAME=boxlinker \
		-e PLUGIN_PASSWORD=QAZwsx123 \
		-v `pwd`:`pwd` \
		-w `pwd` \
		--privileged \
		plugins/docker --dry-run