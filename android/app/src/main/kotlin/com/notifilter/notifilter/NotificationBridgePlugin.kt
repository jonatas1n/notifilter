package com.notifilter.notifilter

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NotificationBridgePlugin(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null

    fun attachToEngine(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME,
        ).also { channel ->
            channel.setMethodCallHandler(this)
        }

        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL_NAME,
        ).also { channel ->
            channel.setStreamHandler(this)
        }
    }

    fun detachFromEngine() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isNotificationAccessGranted" -> {
                result.success(isNotificationAccessGranted())
            }

            "openNotificationAccessSettings" -> {
                openNotificationAccessSettings()
                result.success(null)
            }

            "cancelNotification" -> {
                val notificationKey = call.argument<String>("key")
                if (notificationKey.isNullOrBlank()) {
                    result.error("invalid_argument", "Missing notification key", null)
                    return
                }
                val cancelled = NotificationBridgeHolder.listenerService
                    ?.cancelNotificationByKey(notificationKey)
                    ?: false
                result.success(cancelled)
            }

            "sendNotificationReply" -> {
                // Premium (planned): RemoteInput replies — not called by free-tier Dart.
                val notificationKey = call.argument<String>("key")
                val actionIndex = call.argument<Int>("actionIndex")
                val remoteInputKey = call.argument<String>("remoteInputKey")
                val replyText = call.argument<String>("text")

                if (notificationKey.isNullOrBlank() ||
                    actionIndex == null ||
                    remoteInputKey.isNullOrBlank() ||
                    replyText.isNullOrBlank()
                ) {
                    result.error("invalid_argument", "Missing reply arguments", null)
                    return
                }

                val sent = NotificationBridgeHolder.listenerService?.sendReplyToNotification(
                    notificationKey = notificationKey,
                    actionIndex = actionIndex,
                    remoteInputKey = remoteInputKey,
                    replyText = replyText,
                ) ?: false
                result.success(sent)
            }

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        NotificationBridgeHolder.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        NotificationBridgeHolder.eventSink = null
    }

    private fun isNotificationAccessGranted(): Boolean {
        val enabledListeners = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ) ?: return false

        val componentName = ComponentName(context, NotifilterNotificationListenerService::class.java)
        return enabledListeners.contains(componentName.flattenToString(), ignoreCase = true)
    }

    private fun openNotificationAccessSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    companion object {
        const val METHOD_CHANNEL_NAME = "com.notifilter/notifications"
        const val EVENT_CHANNEL_NAME = "com.notifilter/notification_events"
    }
}
