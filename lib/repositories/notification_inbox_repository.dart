import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/inbox_delivery_state.dart';
import '../models/stored_notification.dart';

class NotificationInboxRepository {
  NotificationInboxRepository(this._database);

  final Database _database;

  static const String tableName = 'inbox_notifications';
  static const int schemaVersion = 2;

  static Future<NotificationInboxRepository> create() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notifilter_inbox.db');

    final database = await openDatabase(
      path,
      version: schemaVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN is_held_suppressed INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE $tableName ADD COLUMN delivery_state TEXT NOT NULL DEFAULT 'held'",
          );
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN delivered_at INTEGER',
          );
        }
      },
    );

    return NotificationInboxRepository(database);
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notification_key TEXT NOT NULL,
            package_name TEXT NOT NULL,
            title TEXT NOT NULL,
            text TEXT NOT NULL,
            post_time INTEGER NOT NULL,
            received_at INTEGER NOT NULL,
            was_emergency_breakthrough INTEGER NOT NULL,
            decision_reason TEXT NOT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            is_held_suppressed INTEGER NOT NULL DEFAULT 0,
            delivery_state TEXT NOT NULL DEFAULT 'held',
            delivered_at INTEGER
          )
        ''');
  }

  Future<int> insertNotification(StoredNotification notification) async {
    return _database.insert(tableName, notification.toMap());
  }

  Future<List<StoredNotification>> fetchAll({bool unreadOnly = false}) async {
    final rows = await _database.query(
      tableName,
      where: unreadOnly ? 'is_read = ?' : null,
      whereArgs: unreadOnly ? [0] : null,
      orderBy: 'received_at DESC',
    );

    return rows.map(StoredNotification.fromMap).toList();
  }

  Future<int> releaseHeldNotificationsForDigest(DateTime deliveredAt) async {
    return _database.update(
      tableName,
      {
        'delivery_state': InboxDeliveryState.delivered.toJson(),
        'delivered_at': deliveredAt.millisecondsSinceEpoch,
        'is_read': 0,
      },
      where: 'delivery_state = ? AND is_held_suppressed = ?',
      whereArgs: [InboxDeliveryState.held.toJson(), 1],
    );
  }

  Future<int> countHeldSuppressed() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as c FROM $tableName WHERE delivery_state = ? AND is_held_suppressed = 1',
      [InboxDeliveryState.held.toJson()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _database.update(
      tableName,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead() async {
    await _database.update(tableName, {'is_read': 1});
  }

  Future<void> deleteNotification(int id) async {
    await _database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
