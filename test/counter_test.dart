import 'package:flutter_test/flutter_test.dart';

int increment(int value) => value + 1;

void main() {
  test('adds one to input values', () {
    expect(increment(2), 3);
    expect(increment(-1), 0);
  });
}