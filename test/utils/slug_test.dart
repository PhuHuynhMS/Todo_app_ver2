import 'package:flutter_test/flutter_test.dart';
import 'package:todo/utils/slug.dart';

void main() {
  group('toSlug', () {
    test('lowercases', () => expect(toSlug('Work'), 'work'));
    test('spaces to hyphens', () => expect(toSlug('affi tiktok'), 'affi-tiktok'));
    test('trims whitespace', () => expect(toSlug('  hello  '), 'hello'));
    test('removes special chars', () => expect(toSlug('hello!@#'), 'hello'));
    test('collapses multiple spaces', () => expect(toSlug('a  b'), 'a-b'));
  });
}
