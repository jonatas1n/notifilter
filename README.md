# Prio

Prio is an Android notification filter built with Flutter. It intercepts status bar notifications through a native `NotificationListenerService`, applies keyword, schedule, condensed-inbox, and emergency-insistence rules on the Dart side, and keeps a local inbox of held alerts.

**Brand:** launcher label and in-app copy use **Prio**. The logo is the **brightness/sun emblem** (cyan `#46BBC2` on a dark `#0B0B0B` badge, or green `#436849` on light) defined in `assets/icon/prio_logo.svg` and rendered by `lib/widgets/prio_logo.dart`.

**Android identity:** `applicationId` is `com.jotadevsol.prio` (must match the `package_name` in `android/app/google-services.json` for Firebase). Kotlin sources live under package `com.prio.prio` with Gradle `namespace = "com.prio.prio"`. The Firebase project itself stays `notifilter-76e70` (server-side id; renaming it would break the existing Firebase app).

## Requirements

- Flutter 3.29+ (Dart 3.7+)
- Android SDK / device or emulator with `adb`
- Notification listener permission granted for the app
- `make` (optional, for build/run shortcuts)

## Setup

```bash
flutter pub get
make run          # or: flutter run -d android
```

Regenerate launcher icons after changing `assets/icon/app_icon.png`:

```bash
dart run flutter_launcher_icons
```

### Typography

UI text uses the **[Outfit](https://fonts.google.com/specimen/Outfit)** family, bundled under `assets/fonts/` (weights 400, 500, 600, 700). The [SIL Open Font License 1.1](assets/fonts/OFL.txt) is included with the font files. No runtime font download is used.

## Make targets

Run `make` or `make help` for the full list. Common workflows:

| Target | Description |
| --- | --- |
| `make apk` | **Slim release** for phones (arm64-v8a) → `./prio.apk` (~8 MB) |
| `make apk-emulator` | Release x86_64 for AVD → `./prio-emulator.apk` |
| `make apk-debug` | Debug APK (larger, JIT) → `./prio-debug.apk` |
| `make apk-release` | Universal release (arm64 + x86_64) → `./prio-release-universal.apk` |
| `make emulator` | Launch the first available Android emulator |
| `make run` | Dev run with hot reload (preferred on emulator) |
| `make install` | `adb install -r ./prio.apk` (arm64 device) |
| `make install-emulator` | Build & install `./prio-emulator.apk` on x86_64 AVD |
| `make test` / `make analyze` | Tests and static analysis |

Typical **phone**: `make apk` → `make install`. **Emulator**: `make emulator` → `make run` (or `make install-emulator` for a release APK on AVD).

Native builds target **arm64-v8a** (phones) and **x86_64** (emulators) via Flutter `--target-platform`; legacy **x86** and **armeabi-v7a** are omitted to keep APKs small.

## Grant notification access

1. Install and open **Prio**.
2. On onboarding (or from the inbox banner), tap **Open notification access settings**.
3. Enable **Prio** in the system Notification access screen.
4. Return to the app and tap **Continuar para o app**.

Without this permission the native listener cannot receive or cancel notifications.

## Architecture (free tier)

| Layer | Responsibility |
| --- | --- |
| **Kotlin** (`PrioNotificationListenerService`) | Receives `StatusBarNotification`s, streams JSON to Flutter, cancels held notifications |
| **MethodChannel** `com.prio/notifications` | Access check, open settings, cancel (channel id kept in sync with Kotlin namespace) |
| **EventChannel** `com.prio/notification_events` | Posted/removed notification payloads |
| **Dart** | `NotificationOrchestratorService` → `NotificationPolicyEngine` → inbox persistence |
| **Persistence** | `sqflite` inbox, `shared_preferences` for rules/schedules/settings |
| **State** | `flutter_riverpod` under `lib/providers/` |

### Free features (shipped)

- Keyword & category filter rules (allow/block)
- Scheduled silence windows
- Condensed inbox + digest windows
- Emergency insistence detector (configurable threshold)

## Premium (não implementado / planejado)

Esta versão entrega **apenas o plano gratuito**. O código Dart de premium (LLM, auto-replies, ecrã Premium, flags `isPremium`) foi removido. A secção abaixo descreve onde ligar funcionalidades pagas no futuro.

### 1. Filtragem contextual com AI / LLM

**Objetivo:** interpretar o contexto real das mensagens (além de keywords estáticas) e aprender com ações do utilizador (ex.: “sempre deixo passar deste contacto”).

**Onde encaixa:**

1. **`lib/services/notification_policy_engine.dart`** — hoje a ordem é: emergência → keywords → silêncio agendado → inbox condensado → permitir. Inserir um passo **depois das keywords e antes do silêncio**, por exemplo:
   - `final llmResult = llmClassifier.classify(notification);`
   - se `shouldHold`, devolver `NotificationDecision` com motivo da IA.
2. **Nova abstração** (a criar): `lib/services/llm/llm_classifier.dart` com `LlmClassificationResult classify(IncomingNotification notification)` e implementações (`StubLlmClassifier`, depois cliente HTTP/on-device).
3. **Aprendizagem:** persistir feedback em `SettingsRepository` ou tabela SQLite dedicada; o classificador lê esse histórico antes de chamar o modelo.
4. **UI:** ecrã de definições premium + toggle “Filtragem inteligente”; gating via Play Billing (`isPremium` em `AppSettings`, removido na build free).
5. **Providers:** registar `LlmClassifier` no Riverpod e injetar no `NotificationPolicyEngine` (construtor ou factory).

### 2. Smart auto-replies

**Objetivo:** sugerir ou enviar respostas contextuais (ex.: “Estou em reunião, falo consigo às 14h”) para notificações com ações de resposta.

**Plumbing nativo (já presente, não usado pela app free):**

- **`PrioNotificationListenerService.sendReplyToNotification`** — monta `RemoteInput`, preenche `Bundle`, envia `PendingIntent` da `Notification.Action`.
- **`NotificationBridgePlugin`** — método `sendNotificationReply` no MethodChannel `com.prio/notifications` (parâmetros: `key`, `actionIndex`, `remoteInputKey`, `text`).
- O payload de eventos já inclui `actions` / `remoteInputs` em JSON (`IncomingNotificationAction` em Dart).

**Onde encaixa no Dart (a implementar com premium):**

1. **`lib/services/notification_bridge_service.dart`** — reexpôr `sendNotificationReply(...)`.
2. **Novo serviço** `lib/services/auto_reply/auto_reply_service.dart` — `suggestReply(IncomingNotification)` (LLM ou templates).
3. **`NotificationOrchestratorService._handleIncomingNotification`** — **após** avaliar política e gravar inbox, se premium + toggle: obter sugestão e chamar o bridge (só se a notificação ainda estiver activa e tiver `RemoteInput`).
4. **UI:** definições de respostas rápidas + confirmação opcional antes de enviar.

**Nota:** a app free **não** invoca `sendNotificationReply`; o listener foca-se em captura, cancelamento e regras gratuitas.

## Project layout

```
lib/
  core/          constants, logging
  models/        domain types
  utils/         pure rule engines (unit tested)
  services/      bridge, policy, orchestrator
  repositories/  sqflite + shared_preferences
  providers/     Riverpod wiring
  screens/       inbox, rules, schedule, emergency, onboarding
  widgets/       prio_logo (leaf SVG), time_window_editor
assets/icon/     prio_logo.svg + app_icon.png for launcher
android/         PrioNotificationListenerService + platform channels
test/            business logic tests
Makefile         apk, run, emulator, install
```

## Tests

```bash
make test
make analyze
```

Or: `flutter test` / `flutter analyze`.

## Build APK

```bash
make apk
```

Output: **`prio.apk`** at the project root — **release, arm64-v8a only** (AOT, R8 minify, ~8 MB vs ~100 MB+ debug fat APK).

- Physical phone (arm64): `make install`
- Android emulator (x86_64): `make run` for development, or `make install-emulator` for a release APK
- Heavy debug build: `make apk-debug`
