import 'package:easy_flutter_architecture/core/storage/storage_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockKVStorage extends Mock implements IKVStorage {}

class MockSecureStorage extends Mock implements ISecureStorage {}

void main() {
  group('IKVStorage', () {
    late MockKVStorage storage;

    setUp(() {
      storage = MockKVStorage();
    });

    test('should save and retrieve string', () async {
      const key = 'test_key';
      const value = 'test_value';

      when(() => storage.setString(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.getString(key))
          .thenAnswer((_) async => value);

      await storage.setString(key, value);
      final result = await storage.getString(key);

      expect(result, equals(value));
      verify(() => storage.setString(key, value)).called(1);
      verify(() => storage.getString(key)).called(1);
    });

    test('should save and retrieve bool', () async {
      const key = 'bool_key';
      const value = true;

      when(() => storage.setBool(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.getBool(key))
          .thenAnswer((_) async => value);

      await storage.setBool(key, value);
      final result = await storage.getBool(key);

      expect(result, isTrue);
    });

    test('should save and retrieve int', () async {
      const key = 'int_key';
      const value = 42;

      when(() => storage.setInt(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.getInt(key))
          .thenAnswer((_) async => value);

      await storage.setInt(key, value);
      final result = await storage.getInt(key);

      expect(result, equals(42));
    });

    test('should save and retrieve double', () async {
      const key = 'double_key';
      const value = 3.14;

      when(() => storage.setDouble(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.getDouble(key))
          .thenAnswer((_) async => value);

      await storage.setDouble(key, value);
      final result = await storage.getDouble(key);

      expect(result, equals(3.14));
    });

    test('should save and retrieve string list', () async {
      const key = 'list_key';
      const value = ['item1', 'item2', 'item3'];

      when(() => storage.setStringList(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.getStringList(key))
          .thenAnswer((_) async => value);

      await storage.setStringList(key, value);
      final result = await storage.getStringList(key);

      expect(result, equals(value));
    });

    test('should remove key', () async {
      const key = 'remove_key';

      when(() => storage.remove(key))
          .thenAnswer((_) async => Future.value());

      await storage.remove(key);

      verify(() => storage.remove(key)).called(1);
    });

    test('should clear all data', () async {
      when(() => storage.clear())
          .thenAnswer((_) async => Future.value());

      await storage.clear();

      verify(() => storage.clear()).called(1);
    });

    test('should check if key exists', () async {
      const key = 'exists_key';

      when(() => storage.containsKey(key))
          .thenAnswer((_) async => true);

      final result = await storage.containsKey(key);

      expect(result, isTrue);
    });
  });

  group('ISecureStorage', () {
    late MockSecureStorage storage;

    setUp(() {
      storage = MockSecureStorage();
    });

    test('should save and read value', () async {
      const key = 'secure_key';
      const value = 'sensitive_data';

      when(() => storage.save(key, value))
          .thenAnswer((_) async => Future.value());
      when(() => storage.read(key))
          .thenAnswer((_) async => value);

      await storage.save(key, value);
      final result = await storage.read(key);

      expect(result, equals(value));
      verify(() => storage.save(key, value)).called(1);
      verify(() => storage.read(key)).called(1);
    });

    test('should delete key', () async {
      const key = 'delete_key';

      when(() => storage.delete(key))
          .thenAnswer((_) async => Future.value());

      await storage.delete(key);

      verify(() => storage.delete(key)).called(1);
    });

    test('should delete all keys', () async {
      when(() => storage.deleteAll())
          .thenAnswer((_) async => Future.value());

      await storage.deleteAll();

      verify(() => storage.deleteAll()).called(1);
    });

    test('should check if key exists', () async {
      const key = 'secure_exists_key';

      when(() => storage.containsKey(key))
          .thenAnswer((_) async => true);

      final result = await storage.containsKey(key);

      expect(result, isTrue);
    });

    test('should get all keys', () async {
      const keys = {'key1', 'key2', 'key3'};

      when(() => storage.getAllKeys())
          .thenAnswer((_) async => keys);

      final result = await storage.getAllKeys();

      expect(result, equals(keys));
    });
  });
}
