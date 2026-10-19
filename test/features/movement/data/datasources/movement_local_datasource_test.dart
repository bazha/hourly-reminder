import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/data/datasources/movement_local_datasource.dart';
import 'package:hourly_reminder/features/movement/data/models/movement_event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

MovementEventModel _event(String id) => MovementEventModel(
      id: id,
      timestampMillis: 0,
      sedentaryDurationMillis: 0,
      reactionTimeMillis: 0,
      source: 'manual',
    );

void main() {
  test('saveEvent keeps an event written behind the Dart cache', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final datasource = MovementLocalDatasource(prefs);
    await datasource.saveEvent(_event('a'));

    // The native pipeline appends 'b' directly to storage. Swapping the
    // store leaves `prefs` with its stale cache, like a native write does.
    SharedPreferences.setMockInitialValues({
      'movement_events': [
        jsonEncode(_event('a').toJson()),
        jsonEncode(_event('b').toJson()),
      ],
    });
    await datasource.saveEvent(_event('c'));

    final events = await datasource.getEvents();
    expect(events.map((e) => e.id), ['a', 'b', 'c']);
  });
}
