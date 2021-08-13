import 'package:flutter_test/flutter_test.dart';
import 'package:super_tooltip/super_tooltip.dart';

// set up
// act
// assert

void main() {
  group(
    '$TipPosition#snapsHorizontal',
    () {
      test(
        'should return true when snapTo is horizontal',
        () {
          // set up
          const tipPosition = TipPosition.snap(SnapAxis.horizontal);
          // assert
          expect(tipPosition.snapsHorizontal, isTrue);
        },
      );

      test(
        'should return true when left & right are 0',
        () {
          // set up
          const tipPosition = TipPosition(
            left: 0,
            right: 0,
          );
          // assert
          expect(tipPosition.snapsHorizontal, isTrue);
        },
      );
    },
  );
}
