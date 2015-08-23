
# Generates documentation for mainline
.PHONY: doc
doc:
	$(eval HASH := $(shell git rev-parse master))
	git show $(HASH):perlin.nim > perlin.nim
	git show $(HASH):simplex.nim > simplex.nim
	git show $(HASH):noise.nim > noise.nim
	nim doc perlin.nim
	nim doc simplex.nim
	nim doc noise.nim
	git add perlin.html simplex.html noise.html
	git commit -m "Generate docs from $(HASH)"

