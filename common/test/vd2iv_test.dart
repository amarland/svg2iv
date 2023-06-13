import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/src/converter/vd2iv.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  group(
    'VectorDrawables are properly converted to ImageVectors;',
    () {
      test(
        ' very minimal',
        () {
          final expected = ImageVectorBuilder(60.0, 60.0)
              .width(32.0)
              .height(32.0)
              .addNode(
                VectorPathBuilder(parsePathData('M30,7L30,0 37,7 30,14Z'))
                    .fill(SolidColor(0xFF000000))
                    .build(),
              )
              .build();
          final actual = parseVectorDrawableElement(
            XmlDocument.parse(veryMinimalVectorDrawable).rootElement,
          );
          expect(actual, expected);
        },
      );
      test(
        ' more complete',
        () {
          final clipPath4 = VectorGroupBuilder()
              .id('clip_path_4')
              .clipPathData(parsePathData('M10,10L12,10 12,12 10,12 10,10Z'))
              .addNode(
                  VectorPathBuilder(parsePathData('M0,0L24,0 24,24 0,24 0,0Z'))
                      .id('path3')
                      .fill(SolidColor(0xFF0000FF))
                      .stroke(SolidColor(0xFFFF0080))
                      .strokeAlpha(0.9)
                      .strokeLineWidth(6.0)
                      .strokeLineCap(StrokeCap.round)
                      .strokeLineJoin(StrokeJoin.bevel)
                      .strokeLineMiter(5.0)
                      .build())
              .build();
          final clipPath3 = VectorGroupBuilder()
              .id('clip_path_3')
              .clipPathData(parsePathData('M8,8L16,8 16,16 8,16 8,8Z'))
              .addNode(clipPath4)
              .build();
          final clipPath2 = VectorGroupBuilder()
              .id('clip_path_2')
              .clipPathData(parsePathData('M4,4L24,4 24,24 4,24 4,4Z'))
              .addNode(
                VectorPathBuilder(parsePathData('M0,0L24,0 24,24 0,24 0,0Z'))
                    .id('path_2')
                    .fill(SolidColor(0xFFFF0000))
                    .fillAlpha(0.6)
                    .build(),
              )
              .addNode(clipPath3)
              .build();
          final group1 = VectorGroupBuilder()
              .id('group_1')
              .transformations(
                TransformationsBuilder()
                    .rotate(10.0, pivotX: 3.0, pivotY: 3.5)
                    .scale(x: 0.9, y: 0.8)
                    .translate(x: 4.0, y: 6.0)
                    .build()!,
              )
              .addNode(clipPath2)
              .build();
          final group2 = VectorGroupBuilder()
              .id('group_2')
              .transformations(
                TransformationsBuilder()
                    .scale(x: 1.2, y: 1.2)
                    .translate(y: 2.0)
                    .build()!,
              )
              .addNode(
                VectorPathBuilder(parsePathData('M0,0L24,0 24,24 0,24 0,0Z'))
                    .id('path_4')
                    .fill(SolidColor(0xFF00FF00))
                    .build(),
              )
              .build();
          final path5 =
              VectorPathBuilder(parsePathData('M17,0L21,0 21,3 17,3 17,0Z'))
                  .fill(SolidColor(0xFF0080FF))
                  .trimPathStart(18.0)
                  .trimPathEnd(20.5)
                  .trimPathOffset(0.5)
                  .build();
          final expected = ImageVectorBuilder(32.0, 32.0)
              .width(24.0)
              .height(24.0)
              .addNode(
                VectorPathBuilder(parsePathData('M21,0H30V9H21ZM23,2V7H28V2Z'))
                    .id('path_1')
                    .fill(SolidColor(0xFFFF8000))
                    .pathFillType(PathFillType.evenOdd)
                    .build(),
              )
              .addNode(
                VectorGroupBuilder()
                    .id('clip_path_1')
                    .clipPathData(parsePathData('M0,0L20,0 20,20 0,20 0,0Z'))
                    .addNode(group1)
                    .addNode(group2)
                    .addNode(path5)
                    .build(),
              )
              .build();
          final actual = parseVectorDrawableElement(
            XmlDocument.parse(moreCompleteVectorDrawable).rootElement,
          );
          expect(actual, expected);
        },
        skip: true,
      );
    },
  );
}

const veryMinimalVectorDrawable = '''
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:height="32dp"
    android:width="32dp"
    android:viewportHeight="60"
    android:viewportWidth="60">
    <path
        android:fillColor="#000"
        android:pathData="M30,7L30,0 37,7 30,14Z" />
</vector>
''';

// modified version of https://gist.github.com/alexjlockwood/b74fc1be361d041867ae8118ef4806fa#file-vector_drawable_demo-xml
const moreCompleteVectorDrawable = '''
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="32"
    android:viewportHeight="32">
    <path
        android:name="path_1"
        android:pathData="M21,0H30V9H21ZM23,2V7H28V2Z"
        android:fillColor="#FF8000"
        android:fillType="evenOdd" />
    <clip-path
        android:name="clip_path_1"
        android:pathData="M0,0L20,0 20,20 0,20 0,0Z" />
    <group
        android:name="group_1"
        android:rotation="10"
        android:pivotX="3"
        android:pivotY="3.5"
        android:scaleX="0.9"
        android:scaleY="0.8"
        android:translateX="4"
        android:translateY="6">
        <clip-path
            android:name="clip_path_2"
            android:pathData="M4,4L24,4 24,24 4,24 4,4Z" />
        <path
            android:name="path_2"
            android:pathData="M0,0L24,0 24,24 0,24 0,0Z"
            android:fillColor="#FF0000"
            android:fillAlpha="0.6" />
        <clip-path
            android:name="clip_path_3"
            android:pathData="M8,8L16,8 16,16 8,16 8,8Z" />
        <clip-path
            android:name="clip_path_4"
            android:pathData="M10,10L12,10 12,12 10,12 10,10Z" />
        <path
            android:name="path_3"
            android:pathData="M0,0L24,0 24,24 0,24 0,0Z"
            android:fillColor="#0000FF"
            android:strokeColor="#FF0080"
            android:strokeAlpha="0.9"
            android:strokeWidth="6"
            android:strokeLineCap="round"
            android:strokeLineJoin="bevel"
            android:strokeLineMiter="5" />
    </group>
    <!-- `pivotX` should be ignored because `rotation` is not set -->
    <group
        android:name="group_2"
        android:pivotX="16"
        android:scaleX="1.2"
        android:translateY="2">
        <path
            android:name="path_4"
            android:pathData="M0,0L24,0 24,24 0,24 0,0Z"
            android:fillColor="#00FF00" />
    </group>
    <path
        android:pathData="M17,0L21,0 21,3 17,3 17,0Z"
        android:fillColor="#0080FF"
        android:trimPathStart="18"
        android:trimPathEnd="20.5"
        android:trimPathOffset="0.5" />
</vector>
''';
