package com.prio.prio

import io.flutter.plugin.common.EventChannel

object NotificationBridgeHolder {
    var eventSink: EventChannel.EventSink? = null
    var listenerService: PrioNotificationListenerService? = null
}
