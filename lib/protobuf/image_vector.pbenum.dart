///
//  Generated code. Do not modify.
//  source: image_vector.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class VectorPath_StrokeCap extends $pb.ProtobufEnum {
  static const VectorPath_StrokeCap CAP_BUTT = VectorPath_StrokeCap._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CAP_BUTT');
  static const VectorPath_StrokeCap CAP_ROUND = VectorPath_StrokeCap._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CAP_ROUND');
  static const VectorPath_StrokeCap CAP_SQUARE = VectorPath_StrokeCap._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CAP_SQUARE');

  static const $core.List<VectorPath_StrokeCap> values = <VectorPath_StrokeCap> [
    CAP_BUTT,
    CAP_ROUND,
    CAP_SQUARE,
  ];

  static final $core.Map<$core.int, VectorPath_StrokeCap> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VectorPath_StrokeCap valueOf($core.int value) => _byValue[value];

  const VectorPath_StrokeCap._($core.int v, $core.String n) : super(v, n);
}

class VectorPath_StrokeJoin extends $pb.ProtobufEnum {
  static const VectorPath_StrokeJoin JOIN_MITER = VectorPath_StrokeJoin._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'JOIN_MITER');
  static const VectorPath_StrokeJoin JOIN_ROUND = VectorPath_StrokeJoin._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'JOIN_ROUND');
  static const VectorPath_StrokeJoin JOIN_BEVEL = VectorPath_StrokeJoin._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'JOIN_BEVEL');

  static const $core.List<VectorPath_StrokeJoin> values = <VectorPath_StrokeJoin> [
    JOIN_MITER,
    JOIN_ROUND,
    JOIN_BEVEL,
  ];

  static final $core.Map<$core.int, VectorPath_StrokeJoin> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VectorPath_StrokeJoin valueOf($core.int value) => _byValue[value];

  const VectorPath_StrokeJoin._($core.int v, $core.String n) : super(v, n);
}

class VectorPath_FillType extends $pb.ProtobufEnum {
  static const VectorPath_FillType NON_ZERO = VectorPath_FillType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'NON_ZERO');
  static const VectorPath_FillType EVEN_ODD = VectorPath_FillType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EVEN_ODD');

  static const $core.List<VectorPath_FillType> values = <VectorPath_FillType> [
    NON_ZERO,
    EVEN_ODD,
  ];

  static final $core.Map<$core.int, VectorPath_FillType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VectorPath_FillType valueOf($core.int value) => _byValue[value];

  const VectorPath_FillType._($core.int v, $core.String n) : super(v, n);
}

class PathNode_Command extends $pb.ProtobufEnum {
  static const PathNode_Command CLOSE = PathNode_Command._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CLOSE');
  static const PathNode_Command MOVE_TO = PathNode_Command._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'MOVE_TO');
  static const PathNode_Command RELATIVE_MOVE_TO = PathNode_Command._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_MOVE_TO');
  static const PathNode_Command LINE_TO = PathNode_Command._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LINE_TO');
  static const PathNode_Command RELATIVE_LINE_TO = PathNode_Command._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_LINE_TO');
  static const PathNode_Command HORIZONTAL_LINE_TO = PathNode_Command._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'HORIZONTAL_LINE_TO');
  static const PathNode_Command RELATIVE_HORIZONTAL_LINE_TO = PathNode_Command._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_HORIZONTAL_LINE_TO');
  static const PathNode_Command VERTICAL_LINE_TO = PathNode_Command._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'VERTICAL_LINE_TO');
  static const PathNode_Command RELATIVE_VERTICAL_LINE_TO = PathNode_Command._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_VERTICAL_LINE_TO');
  static const PathNode_Command CURVE_TO = PathNode_Command._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CURVE_TO');
  static const PathNode_Command RELATIVE_CURVE_TO = PathNode_Command._(10, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_CURVE_TO');
  static const PathNode_Command SMOOTH_CURVE_TO = PathNode_Command._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SMOOTH_CURVE_TO');
  static const PathNode_Command RELATIVE_SMOOTH_CURVE_TO = PathNode_Command._(12, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_SMOOTH_CURVE_TO');
  static const PathNode_Command QUADRATIC_BEZIER_CURVE_TO = PathNode_Command._(13, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'QUADRATIC_BEZIER_CURVE_TO');
  static const PathNode_Command RELATIVE_QUADRATIC_BEZIER_CURVE_TO = PathNode_Command._(14, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_QUADRATIC_BEZIER_CURVE_TO');
  static const PathNode_Command SMOOTH_QUADRATIC_BEZIER_CURVE_TO = PathNode_Command._(15, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SMOOTH_QUADRATIC_BEZIER_CURVE_TO');
  static const PathNode_Command RELATIVE_SMOOTH_QUADRATIC_BEZIER_CURVE_TO = PathNode_Command._(16, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_SMOOTH_QUADRATIC_BEZIER_CURVE_TO');
  static const PathNode_Command ARC_TO = PathNode_Command._(17, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ARC_TO');
  static const PathNode_Command RELATIVE_ARC_TO = PathNode_Command._(18, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RELATIVE_ARC_TO');

  static const $core.List<PathNode_Command> values = <PathNode_Command> [
    CLOSE,
    MOVE_TO,
    RELATIVE_MOVE_TO,
    LINE_TO,
    RELATIVE_LINE_TO,
    HORIZONTAL_LINE_TO,
    RELATIVE_HORIZONTAL_LINE_TO,
    VERTICAL_LINE_TO,
    RELATIVE_VERTICAL_LINE_TO,
    CURVE_TO,
    RELATIVE_CURVE_TO,
    SMOOTH_CURVE_TO,
    RELATIVE_SMOOTH_CURVE_TO,
    QUADRATIC_BEZIER_CURVE_TO,
    RELATIVE_QUADRATIC_BEZIER_CURVE_TO,
    SMOOTH_QUADRATIC_BEZIER_CURVE_TO,
    RELATIVE_SMOOTH_QUADRATIC_BEZIER_CURVE_TO,
    ARC_TO,
    RELATIVE_ARC_TO,
  ];

  static final $core.Map<$core.int, PathNode_Command> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PathNode_Command valueOf($core.int value) => _byValue[value];

  const PathNode_Command._($core.int v, $core.String n) : super(v, n);
}

class Gradient_TileMode extends $pb.ProtobufEnum {
  static const Gradient_TileMode CLAMP = Gradient_TileMode._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CLAMP');
  static const Gradient_TileMode REPEATED = Gradient_TileMode._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'REPEATED');
  static const Gradient_TileMode MIRROR = Gradient_TileMode._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'MIRROR');

  static const $core.List<Gradient_TileMode> values = <Gradient_TileMode> [
    CLAMP,
    REPEATED,
    MIRROR,
  ];

  static final $core.Map<$core.int, Gradient_TileMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Gradient_TileMode valueOf($core.int value) => _byValue[value];

  const Gradient_TileMode._($core.int v, $core.String n) : super(v, n);
}
