import 'package:easy_flutter_architecture/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should hold data correctly', () {
        const result = Success<int>(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.dataOrNull, equals(42));
        expect(result.errorOrNull, isNull);
      });

      test('should map data correctly', () {
        const result = Success<int>(42);
        final mapped = result.map((data) => data.toString());

        expect(mapped.dataOrNull, equals('42'));
        expect(mapped.isSuccess, isTrue);
      });

      test('should execute onSuccess callback', () {
        const result = Success<int>(42);
        var executed = false;

        result.onSuccess((data) {
          executed = true;
          expect(data, equals(42));
        });

        expect(executed, isTrue);
      });

      test('should not execute onFailure callback', () {
        const result = Success<int>(42);
        var executed = false;

        result.onFailure((message, code) {
          executed = true;
        });

        expect(executed, isFalse);
      });

      test('should return data from getOrElse', () {
        const result = Success<int>(42);

        expect(result.getOrElse(0), equals(42));
      });

      test('should return data from getOrThrow', () {
        const result = Success<int>(42);

        expect(result.getOrThrow(), equals(42));
      });
    });

    group('Failure', () {
      test('should hold error correctly', () {
        const result = Failure<int>(message: 'Error message', code: 400);

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.dataOrNull, isNull);
        expect(result.errorOrNull, equals('Error message'));
      });

      test('should preserve message and code when mapping', () {
        const result = Failure<int>(message: 'Error', code: 500);
        final mapped = result.map((data) => data.toString());

        expect(mapped.errorOrNull, equals('Error'));
        expect((mapped as Failure).code, equals(500));
      });

      test('should execute onFailure callback', () {
        const result = Failure<int>(message: 'Error', code: 404);
        var executed = false;

        result.onFailure((message, code) {
          executed = true;
          expect(message, equals('Error'));
          expect(code, equals(404));
        });

        expect(executed, isTrue);
      });

      test('should not execute onSuccess callback', () {
        const result = Failure<int>(message: 'Error');
        var executed = false;

        result.onSuccess((data) {
          executed = true;
        });

        expect(executed, isFalse);
      });

      test('should return default value from getOrElse', () {
        const result = Failure<int>(message: 'Error');

        expect(result.getOrElse(99), equals(99));
      });

      test('should throw exception from getOrThrow', () {
        const result = Failure<int>(message: 'Error', code: 500);

        expect(
          () => result.getOrThrow(),
          throwsException,
        );
      });
    });

    group('ResultExtension', () {
      test('should wrap value as Success', () {
        final result = 42.success;

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(42));
      });
    });
  });

  group('PageResult', () {
    test('should create with correct properties', () {
      const result = PageResult<String>(
        items: ['a', 'b', 'c'],
        total: 100,
        page: 1,
        pageSize: 20,
        hasMore: true,
      );

      expect(result.items.length, equals(3));
      expect(result.total, equals(100));
      expect(result.page, equals(1));
      expect(result.pageSize, equals(20));
      expect(result.hasMore, isTrue);
      expect(result.totalPages, equals(5));
      expect(result.isEmpty, isFalse);
      expect(result.isNotEmpty, isTrue);
    });

    test('should create from JSON', () {
      final json = {
        'items': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
        'total': 50,
        'page': 2,
        'pageSize': 10,
      };

      final result = PageResult<Map<String, dynamic>>.fromJson(
        json,
        (item) => item as Map<String, dynamic>,
      );

      expect(result.items.length, equals(2));
      expect(result.total, equals(50));
      expect(result.page, equals(2));
      expect(result.pageSize, equals(10));
      expect(result.hasMore, isTrue);
    });

    test('should map items correctly', () {
      const result = PageResult<int>(
        items: [1, 2, 3],
        total: 3,
        page: 1,
        pageSize: 10,
        hasMore: false,
      );

      final mapped = result.map((item) => item * 2);

      expect(mapped.items, equals([2, 4, 6]));
      expect(mapped.total, equals(3));
    });
  });
}
