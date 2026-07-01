package com.prio.prio

import android.app.Notification
import android.app.RemoteInput
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

class PrioNotificationListenerService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        NotificationBridgeHolder.listenerService = this
        Log.i(TAG, "Notification listener connected")
    }

    override fun onListenerDisconnected() {
        NotificationBridgeHolder.listenerService = null
        super.onListenerDisconnected()
        Log.i(TAG, "Notification listener disconnected")
    }

    override fun onNotificationPosted(statusBarNotification: StatusBarNotification) {
        val payload = statusBarNotification.toPayloadJson()
        NotificationBridgeHolder.eventSink?.success(payload.toString())
    }

    override fun onNotificationRemoved(statusBarNotification: StatusBarNotification) {
        val payload = JSONObject()
        payload.put("eventType", "removed")
        payload.put("key", statusBarNotification.key)
        NotificationBridgeHolder.eventSink?.success(payload.toString())
    }

    fun cancelNotificationByKey(notificationKey: String): Boolean {
        return try {
            cancelNotification(notificationKey)
            true
        } catch (exception: Exception) {
            Log.e(TAG, "Failed to cancel notification", exception)
            false
        }
    }

    fun sendReplyToNotification(
        notificationKey: String,
        actionIndex: Int,
        remoteInputKey: String,
        replyText: String,
    ): Boolean {
        val activeNotification = activeNotifications?.firstOrNull { it.key == notificationKey }
            ?: return false

        val action = activeNotification.notification.actions?.getOrNull(actionIndex)
            ?: return false

        val remoteInputs = action.remoteInputs ?: return false
        val targetRemoteInput = remoteInputs.firstOrNull { it.resultKey == remoteInputKey }
            ?: remoteInputs.firstOrNull()
            ?: return false

        return try {
            val intent = Intent()
            val bundle = Bundle()
            bundle.putCharSequence(targetRemoteInput.resultKey, replyText)
            RemoteInput.addResultsToIntent(arrayOf(targetRemoteInput), intent, bundle)
            action.actionIntent.send(this, 0, intent)
            true
        } catch (exception: Exception) {
            Log.e(TAG, "Failed to send notification reply", exception)
            false
        }
    }

    private fun StatusBarNotification.toPayloadJson(): JSONObject {
        val extras = notification.extras
        val title = extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras?.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()

        val payload = JSONObject()
        payload.put("eventType", "posted")
        payload.put("key", key)
        payload.put("packageName", packageName)
        payload.put("title", title)
        payload.put("text", text)
        payload.put("bigText", bigText ?: JSONObject.NULL)
        payload.put("postTime", postTime)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            payload.put("channelId", notification.channelId ?: JSONObject.NULL)
        }
        payload.put("category", notification.category ?: JSONObject.NULL)
        payload.put("actions", notificationActionsToJson(notification))
        return payload
    }

    private fun notificationActionsToJson(notification: Notification): JSONArray {
        val actionsArray = JSONArray()
        val actions = notification.actions ?: return actionsArray

        actions.forEachIndexed { index, action ->
            val actionObject = JSONObject()
            actionObject.put("index", index)
            actionObject.put("title", action.title?.toString() ?: "")
            val remoteInputs = action.remoteInputs
            if (remoteInputs != null && remoteInputs.isNotEmpty()) {
                val remoteInputArray = JSONArray()
                remoteInputs.forEach { remoteInput ->
                    val remoteInputObject = JSONObject()
                    remoteInputObject.put("resultKey", remoteInput.resultKey)
                    remoteInputObject.put("label", remoteInput.label?.toString() ?: "")
                    remoteInputArray.put(remoteInputObject)
                }
                actionObject.put("remoteInputs", remoteInputArray)
            }
            actionsArray.put(actionObject)
        }
        return actionsArray
    }

    companion object {
        private const val TAG = "PrioNLS"
    }
}
