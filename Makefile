FLUTTER ?= /Applications/flutter/bin/flutter
ADB ?= adb
APK_DEBUG := build/app/outputs/flutter-apk/app-debug.apk
APK_RELEASE := build/app/outputs/flutter-apk/app-release.apk
ROOT_APK := notifilter.apk
ROOT_APK_DEBUG := notifilter-debug.apk
ROOT_APK_EMULATOR := notifilter-emulator.apk
ROOT_APK_RELEASE_ALL := notifilter-release-universal.apk

# Only arm64 (phones) and x64 (emulators) — no legacy x86 or armeabi-v7a.
PLATFORM_PHONE := android-arm64
PLATFORM_EMULATOR := android-x64
PLATFORMS_BOTH := android-arm64,android-x64

.PHONY: help pub-get analyze test apk apk-debug apk-emulator apk-release run emulator install install-emulator devices clean

help:
	@echo "Notifilter — make targets"
	@echo ""
	@echo "  make pub-get          flutter pub get"
	@echo "  make analyze          flutter analyze"
	@echo "  make test             flutter test"
	@echo "  make apk              Release arm64 -> ./$(ROOT_APK) (~8 MB, real phones)"
	@echo "  make apk-emulator     Release x86_64 -> ./$(ROOT_APK_EMULATOR) (AVD install)"
	@echo "  make apk-debug        Debug arm64+x64 -> ./$(ROOT_APK_DEBUG) (dev only, smaller than old fat debug)"
	@echo "  make apk-release      Release arm64+x64 universal -> ./$(ROOT_APK_RELEASE_ALL)"
	@echo "  make run              flutter run -d android (emulator/dev; hot reload)"
	@echo "  make emulator         Launch first available Android emulator"
	@echo "  make install          adb install ./$(ROOT_APK) (arm64 device)"
	@echo "  make install-emulator adb install ./$(ROOT_APK_EMULATOR) (x86_64 AVD)"
	@echo "  make devices          List flutter devices"
	@echo "  make clean            flutter clean"

pub-get:
	$(FLUTTER) pub get

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

apk: pub-get
	$(FLUTTER) build apk --release --target-platform $(PLATFORM_PHONE)
	cp $(APK_RELEASE) $(ROOT_APK)
	@ls -lh $(ROOT_APK)
	@echo "Phone APK (arm64-v8a release): $(CURDIR)/$(ROOT_APK)"

apk-emulator: pub-get
	$(FLUTTER) build apk --release --target-platform $(PLATFORM_EMULATOR)
	cp $(APK_RELEASE) $(ROOT_APK_EMULATOR)
	@ls -lh $(ROOT_APK_EMULATOR)
	@echo "Emulator APK (x86_64 release): $(CURDIR)/$(ROOT_APK_EMULATOR)"

apk-debug: pub-get
	$(FLUTTER) build apk --debug --target-platform $(PLATFORMS_BOTH)
	cp $(APK_DEBUG) $(ROOT_APK_DEBUG)
	@ls -lh $(ROOT_APK_DEBUG)
	@echo "Debug APK: $(CURDIR)/$(ROOT_APK_DEBUG)"

apk-release: pub-get
	$(FLUTTER) build apk --release --target-platform $(PLATFORMS_BOTH)
	cp $(APK_RELEASE) $(ROOT_APK_RELEASE_ALL)
	@ls -lh $(ROOT_APK_RELEASE_ALL)
	@echo "Universal release APK (arm64 + x86_64): $(CURDIR)/$(ROOT_APK_RELEASE_ALL)"

run: pub-get
	$(FLUTTER) run -d android

emulator:
	@id=$$($(FLUTTER) emulators 2>/dev/null | awk '$$1 ~ /^[A-Za-z0-9_]+$$/ && $$1 != "Id" && $$1 != "To" {print $$1; exit}'); \
	if [ -z "$$id" ]; then \
	  echo "No Android emulators found. Create one in Android Studio."; \
	  exit 1; \
	fi; \
	echo "Launching emulator: $$id"; \
	$(FLUTTER) emulators --launch "$$id"

install: apk
	$(ADB) install -r $(ROOT_APK)

install-emulator: apk-emulator
	$(ADB) install -r $(ROOT_APK_EMULATOR)

devices:
	$(FLUTTER) devices

clean:
	$(FLUTTER) clean
