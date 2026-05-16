APP_NAME = Tuntun
VERSION  = 0.1.0
BIN      = .build/apple/Products/Release/Tuntun

.PHONY: all build universal bundle install dmg clean

all: bundle

build:
	swift build -c release

universal:
	swift build -c release --arch arm64 --arch x86_64

bundle: universal
	@rm -rf $(APP_NAME).app
	@mkdir -p $(APP_NAME).app/Contents/MacOS
	@mkdir -p $(APP_NAME).app/Contents/Resources
	cp $(BIN) $(APP_NAME).app/Contents/MacOS/Tuntun
	cp Resources/Info.plist $(APP_NAME).app/Contents/
	@if [ -f Resources/AppIcon.icns ]; then \
	    cp Resources/AppIcon.icns $(APP_NAME).app/Contents/Resources/; \
	fi
	codesign --force --deep --sign - $(APP_NAME).app
	@echo "✓ built $(APP_NAME).app"

install: bundle
	@rm -rf /Applications/$(APP_NAME).app
	@cp -R $(APP_NAME).app /Applications/
	@xattr -dr com.apple.quarantine /Applications/$(APP_NAME).app 2>/dev/null || true
	@echo "✓ installed to /Applications/$(APP_NAME).app"

dmg: bundle
	@hdiutil create -volname "$(APP_NAME) $(VERSION)" \
	    -srcfolder $(APP_NAME).app \
	    -ov -format UDZO \
	    $(APP_NAME)_$(VERSION).dmg
	@echo "✓ created $(APP_NAME)_$(VERSION).dmg"

clean:
	swift package clean
	rm -rf .build $(APP_NAME).app $(APP_NAME)_*.dmg
