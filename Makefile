APP_NAME = FastClock
BUNDLE_NAME = $(APP_NAME).app
BUNDLE_CONTENTS = $(BUNDLE_NAME)/Contents
BUNDLE_MACOS = $(BUNDLE_CONTENTS)/MacOS
BUNDLE_RESOURCES = $(BUNDLE_CONTENTS)/Resources

SOURCES = Sources/*.swift

.PHONY: all clean build package install

all: package

build:
	@echo "Building $(APP_NAME)..."
	@swiftc $(SOURCES) -o $(APP_NAME) -framework Cocoa

package: build
	@echo "Packaging $(BUNDLE_NAME)..."
	@rm -rf $(BUNDLE_NAME)
	@mkdir -p $(BUNDLE_MACOS)
	@mkdir -p $(BUNDLE_RESOURCES)
	@cp $(APP_NAME) $(BUNDLE_MACOS)/
	@cp Info.plist $(BUNDLE_CONTENTS)/
	@echo "Created $(BUNDLE_NAME)"

install: package
	@echo "Installing to /Applications..."
	@rm -rf /Applications/$(BUNDLE_NAME)
	@cp -R $(BUNDLE_NAME) /Applications/
	@echo "Installed to /Applications/$(BUNDLE_NAME)"

clean:
	@echo "Cleaning..."
	@rm -f $(APP_NAME)
	@rm -rf $(BUNDLE_NAME)
	@echo "Clean complete"
