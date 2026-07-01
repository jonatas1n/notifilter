package com.prio.prio

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var notificationBridgePlugin: NotificationBridgePlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        notificationBridgePlugin = NotificationBridgePlugin(applicationContext).also { plugin ->
            plugin.attachToEngine(flutterEngine)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        notificationBridgePlugin?.detachFromEngine()
        notificationBridgePlugin = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
