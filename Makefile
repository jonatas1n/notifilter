FLUTTER ?= /Applications/flutter/bin/flutter
ADB ?= adb
APK_DEBUG := build/app/outputs/flutter-apk/app-debug.apk
APK_RELEASE := build/app/outputs/flutter-apk/app-release.apk
ROOT_APK := prio.apk
ROOT_APK_DEBUG := prio-debug.apk
ROOT_APK_EMULATOR := prio-emulator.apk

# Firebase App Distribution. App ID = mobilesdk_app_id from google-services.json.
# Uses the installed `firebase` CLI when present, otherwise falls back to npx.
FIREBASE := $(shell command -v firebase 2>/dev/null || echo "npx --yes firebase-tools")
FIREBASE_APP_ID ?= 1:408351892647:android:3a0f31b8b22e888ee3e782
FIREBASE_TESTERS ?= jonatasgeek@gmail.com
FIREBASE_RELEASE_NOTES ?= Prio test build

# Only arm64 (phones) and x64 (emulators) — no legacy x86 or armeabi-v7a.
PLATFORM_PHONE := android-arm64
PLATFORM_EMULATOR := android-x64
PLATFORMS_BOTH := android-arm64,android-x64

.PHONY: help pub-get analyze test apk apk-debug apk-emulator firebase-distribute run emulator install install-emulator devices clean

help:
	@echo "Prio — make targets"
	@echo ""
	@echo "  make pub-get          flutter pub get"
	@echo "  make analyze          flutter analyze"
	@echo "  make test             flutter test"
	@echo "  make apk              Release arm64+x64 universal -> ./$(ROOT_APK) (phones + emulators)"
	@echo "  make apk-emulator     Release x86_64 -> ./$(ROOT_APK_EMULATOR) (AVD install)"
	@echo "  make apk-debug        Debug arm64+x64 -> ./$(ROOT_APK_DEBUG) (dev only, smaller than old fat debug)"
	@echo "  make firebase-distribute  Build ./$(ROOT_APK) and upload to Firebase App Distribution ($(FIREBASE_TESTERS))"
	@echo "  make run              flutter run -d android (emulator/dev; hot reload)"
	@echo "  make emulator         Launch first available Android emulator"
	@echo "  make install          adb install ./$(ROOT_APK) (phone or emulator)"
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
	$(FLUTTER) build apk --release --target-platform $(PLATFORMS_BOTH)
	cp $(APK_RELEASE) $(ROOT_APK)
	@ls -lh $(ROOT_APK)
	@echo "Universal release APK (arm64 + x86_64): $(CURDIR)/$(ROOT_APK)"

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

# Build the test APK and ship it to Firebase App Distribution.
# Auth: run `firebase login` once, or export GOOGLE_APPLICATION_CREDENTIALS
# (service account JSON with the Firebase App Distribution Admin role).
firebase-distribute: apk
	$(FIREBASE) appdistribution:distribute "$(ROOT_APK)" \
		--app "$(FIREBASE_APP_ID)" \
		--testers "$(FIREBASE_TESTERS)" \
		--release-notes "$(FIREBASE_RELEASE_NOTES)"
	@echo "Distributed $(ROOT_APK) to: $(FIREBASE_TESTERS)"

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
