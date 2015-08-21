
# Generates documentation for mainline
.PHONY: doc
doc:
	$(eval HASH := $(shell git rev-parse master))
	git show $(HASH):perlin.nim > perlin.nim
	nim doc perlin.nim
	git add perlin.html
	git commit -m "Generate docs from $(HASH)"

