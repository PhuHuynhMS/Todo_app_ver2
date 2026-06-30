import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/utils/task_auto_detect.dart';

void main() {
  final categories = seedCategories.toList();

  group('detectCategory', () {
    test('buy from "mua"',       () => expect(detectCategory('mua sữa', categories), 'buy'));
    test('work from "họp"',      () => expect(detectCategory('họp sync', categories), 'work'));
    test('personal from "gọi"',  () => expect(detectCategory('gọi điện', categories), 'personal'));
    test('startup from "investor"', () => expect(detectCategory('gặp investor', categories), 'startup'));
    test('null for unmatched',   () => expect(detectCategory('xyz abc', categories), null));
  });

  group('detectPriority', () {
    test('high for "gấp"',    () => expect(detectPriority('làm gấp'), TaskPriority.high));
    test('high for "urgent"', () => expect(detectPriority('urgent task'), TaskPriority.high));
    test('mid for "hôm nay"', () => expect(detectPriority('làm hôm nay'), TaskPriority.mid));
    test('low for generic',   () => expect(detectPriority('mua bánh'), TaskPriority.low));
  });
}
