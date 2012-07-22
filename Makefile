MODEL=64

TARGETS=bin/dmd lib/libdruntime-osx$(MODEL).a lib/libphobos2.a

all: $(TARGETS)

update:
	git submodule -q foreach git pull -q origin master

bin/dmd: update
	cd dmd/src && make -f posix.mak clean && MODEL=$(MODEL) make -f posix.mak
	mkdir -p bin && cp dmd/src/dmd bin/

lib/libdruntime-osx$(MODEL).a: bin/dmd update
	export PATH=$(PWD)/bin/dmd:$(PATH)
	cd druntime && make -f posix.mak clean && MODEL=$(MODEL) make -f posix.mak
	mkdir -p lib && cp druntime/lib/libdruntime-osx$(MODEL).a lib/
	-rm -rf src/druntime
	mkdir -p src/druntime
	cp -a druntime/import src/druntime

lib/libphobos2.a: bin/dmd lib/libdruntime-osx$(MODEL).a update
	export PATH=$(PWD)/bin/dmd:$(PATH)
	cd phobos && make -f posix.mak clean && MODEL=$(MODEL) make -f posix.mak
	mkdir -p lib && cp phobos/generated/osx/release/$(MODEL)/libphobos2.a lib/
	-rm -rf src/phobos
	mkdir -p src/phobos
	cp -a phobos/std src/phobos/

clean:
	rm -rf $(TARGETS)
