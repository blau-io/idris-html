.PHONY: docs

default:
	idris -p idrisscript -p hrTime -p webgl -i src

deps:
	cd lib/IdrisScript;               \
	idris --install idrisscript.ipkg; \
	cd -;                             \
	cd lib/idris-hrTime;              \
	idris --install hrTime.ipkg;      \
	cd -;                             \
	cd lib/idris-webgl;               \
	idris --install webgl.ipkg;       \
	cd -

docs:
	rm -rf docs;            \
	idris --mkdoc html.ipkg; \
	mv html_doc docs

test:
	idris --checkpkg html.ipkg
