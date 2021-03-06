# Compiler flags.
CFLAGS = -std=c99 -Wall -Werror
# TODO: Add -Wextra.
DEBUG_CFLAGS = -O0 -DDEBUG
RELEASE_CFLAGS = -Os

# Files.
SOURCES = $(wildcard src/*.c)
HEADERS = $(wildcard src/*.h)
OBJECTS = $(SOURCES:.c=.o)

DEBUG_OBJECTS = $(addprefix build/debug/, $(notdir $(OBJECTS)))
RELEASE_OBJECTS = $(addprefix build/release/, $(notdir $(OBJECTS)))

.PHONY: all clean test docs corelib

all: release

# Debug build.
debug: prep wrend

wrend: $(DEBUG_OBJECTS)
	$(CC) $(CFLAGS) $(DEBUG_CFLAGS) -Iinclude -o wrend $^

build/debug/%.o: src/%.c include/wren.h $(HEADERS)
	$(CC) -c $(CFLAGS) $(DEBUG_CFLAGS) -Iinclude -o $@ $<

# Release build.
release: prep wren

wren: $(RELEASE_OBJECTS)
	$(CC) $(CFLAGS) $(RELEASE_CFLAGS) -Iinclude -o wren $^

build/release/%.o: src/%.c include/wren.h $(HEADERS)
	$(CC) -c $(CFLAGS) $(RELEASE_CFLAGS) -Iinclude -o $@ $<

clean:
	rm -rf build wren wrend

prep:
	mkdir -p build/debug build/release

# Run the tests against the debug build of Wren.
test: debug
	@./script/test.py

# Generate the Wren site.
docs:
	@./script/generate_docs.py

# Continuously generate the Wren site.
watchdocs:
	@./script/generate_docs.py --watch

# Take the contents of corelib.wren and copy them into src/wren_core.c.
corelib:
	@./script/generate_corelib.py
