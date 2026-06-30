package com.notifilter.notifilter

import io.flutter.plugin.common.EventChannel

object NotificationBridgeHolder {
    var eventSink: EventChannel.EventSink? = null
    var listenerService: NotifilterNotificationListenerService? = null
}
