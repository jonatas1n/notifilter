import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/constants/channel_names.dart';
import '../core/logging/app_logger.dart';
import '../models/incoming_notification.dart';

class NotificationBridgeService {
  NotificationBridgeService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel = methodChannel ??
            const MethodChannel(NotificationChannelNames.methodChannel),
        _eventChannel = eventChannel ??
            const EventChannel(NotificationChannelNames.eventChannel);

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<IncomingNotification>? _notificationStream;

  Stream<IncomingNotification> watchNotifications() {
    _notificationStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) {
        if (event is! String) {
          throw StateError('Unexpected notification event payload');
        }
        final decoded = jsonDecode(event) as Map<String, dynamic>;
        return IncomingNotification.fromEventPayload(decoded);
      },
    ).handleError((Object error, StackTrace stackTrace) {
      appLogger.e(
        'Notification event stream error',
        error: error,
        stackTrace: stackTrace,
      );
      throw error;
    });

    return _notificationStream!;
  }

  Future<bool> isNotificationAccessGranted() async {
    try {
      final granted = await _methodChannel.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );
      return granted ?? false;
    } on PlatformException catch (error, stackTrace) {
      appLogger.e(
        'Failed to read notification access',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> openNotificationAccessSettings() async {
    try {
      await _methodChannel.invokeMethod<void>('openNotificationAccessSettings');
    } on PlatformException catch (error, stackTrace) {
      appLogger.e(
        'Failed to open notification settings',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> cancelNotification(String notificationKey) async {
    try {
      final cancelled = await _methodChannel.invokeMethod<bool>(
        'cancelNotification',
        {'key': notificationKey},
      );
      return cancelled ?? false;
    } on PlatformException catch (error, stackTrace) {
      appLogger.e(
        'Failed to cancel notification',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
