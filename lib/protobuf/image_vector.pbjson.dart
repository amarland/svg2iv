///
//  Generated code. Do not modify.
//  source: image_vector.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

const Null$json = const {
  '1': 'Null',
  '2': const [
    const {'1': 'NOTHING', '2': 0},
  ],
};

const ImageVectorCollection$json = const {
  '1': 'ImageVectorCollection',
  '2': const [
    const {'1': 'nullable_image_vectors', '3': 1, '4': 3, '5': 11, '6': '.svg2iv.protobuf.NullableImageVector', '10': 'nullableImageVectors'},
  ],
};

const NullableImageVector$json = const {
  '1': 'NullableImageVector',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 11, '6': '.svg2iv.protobuf.ImageVector', '9': 0, '10': 'value'},
    const {'1': 'nothing', '3': 2, '4': 1, '5': 14, '6': '.svg2iv.protobuf.Null', '9': 0, '10': 'nothing'},
  ],
  '8': const [
    const {'1': 'value_or_nothing'},
  ],
};

const ImageVector$json = const {
  '1': 'ImageVector',
  '2': const [
    const {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.svg2iv.protobuf.VectorGroup', '10': 'group'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'viewport_width', '3': 3, '4': 1, '5': 2, '10': 'viewportWidth'},
    const {'1': 'viewport_height', '3': 4, '4': 1, '5': 2, '10': 'viewportHeight'},
    const {'1': 'width', '3': 5, '4': 1, '5': 2, '10': 'width'},
    const {'1': 'height', '3': 6, '4': 1, '5': 2, '10': 'height'},
  ],
};

const VectorNode$json = const {
  '1': 'VectorNode',
  '2': const [
    const {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.svg2iv.protobuf.VectorGroup', '9': 0, '10': 'group'},
    const {'1': 'path', '3': 2, '4': 1, '5': 11, '6': '.svg2iv.protobuf.VectorPath', '9': 0, '10': 'path'},
  ],
  '8': const [
    const {'1': 'node'},
  ],
};

const VectorGroup$json = const {
  '1': 'VectorGroup',
  '2': const [
    const {'1': 'nodes', '3': 1, '4': 3, '5': 11, '6': '.svg2iv.protobuf.VectorNode', '10': 'nodes'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'rotation', '3': 3, '4': 1, '5': 2, '10': 'rotation'},
    const {'1': 'pivot_x', '3': 4, '4': 1, '5': 2, '10': 'pivotX'},
    const {'1': 'pivot_y', '3': 5, '4': 1, '5': 2, '10': 'pivotY'},
    const {'1': 'scale_x', '3': 6, '4': 1, '5': 2, '10': 'scaleX'},
    const {'1': 'scale_y', '3': 10, '4': 1, '5': 2, '10': 'scaleY'},
    const {'1': 'translation_x', '3': 7, '4': 1, '5': 2, '10': 'translationX'},
    const {'1': 'translation_y', '3': 8, '4': 1, '5': 2, '10': 'translationY'},
    const {'1': 'clip_path_data', '3': 9, '4': 3, '5': 11, '6': '.svg2iv.protobuf.PathNode', '10': 'clipPathData'},
  ],
};

const VectorPath$json = const {
  '1': 'VectorPath',
  '2': const [
    const {'1': 'path_nodes', '3': 1, '4': 3, '5': 11, '6': '.svg2iv.protobuf.PathNode', '10': 'pathNodes'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'fill', '3': 3, '4': 1, '5': 11, '6': '.svg2iv.protobuf.Brush', '10': 'fill'},
    const {'1': 'fill_alpha', '3': 4, '4': 1, '5': 2, '10': 'fillAlpha'},
    const {'1': 'stroke', '3': 5, '4': 1, '5': 11, '6': '.svg2iv.protobuf.Brush', '10': 'stroke'},
    const {'1': 'stroke_alpha', '3': 6, '4': 1, '5': 2, '10': 'strokeAlpha'},
    const {'1': 'stroke_line_width', '3': 7, '4': 1, '5': 2, '10': 'strokeLineWidth'},
    const {'1': 'stroke_line_cap', '3': 9, '4': 1, '5': 14, '6': '.svg2iv.protobuf.VectorPath.StrokeCap', '10': 'strokeLineCap'},
    const {'1': 'stroke_line_join', '3': 10, '4': 1, '5': 14, '6': '.svg2iv.protobuf.VectorPath.StrokeJoin', '10': 'strokeLineJoin'},
    const {'1': 'stroke_line_miter', '3': 11, '4': 1, '5': 2, '10': 'strokeLineMiter'},
    const {'1': 'fill_type', '3': 8, '4': 1, '5': 14, '6': '.svg2iv.protobuf.VectorPath.FillType', '10': 'fillType'},
  ],
  '4': const [VectorPath_StrokeCap$json, VectorPath_StrokeJoin$json, VectorPath_FillType$json],
};

const VectorPath_StrokeCap$json = const {
  '1': 'StrokeCap',
  '2': const [
    const {'1': 'CAP_BUTT', '2': 0},
    const {'1': 'CAP_ROUND', '2': 1},
    const {'1': 'CAP_SQUARE', '2': 2},
  ],
};

const VectorPath_StrokeJoin$json = const {
  '1': 'StrokeJoin',
  '2': const [
    const {'1': 'JOIN_MITER', '2': 0},
    const {'1': 'JOIN_ROUND', '2': 1},
    const {'1': 'JOIN_BEVEL', '2': 2},
  ],
};

const VectorPath_FillType$json = const {
  '1': 'FillType',
  '2': const [
    const {'1': 'NON_ZERO', '2': 0},
    const {'1': 'EVEN_ODD', '2': 1},
  ],
};

const PathNode$json = const {
  '1': 'PathNode',
  '2': const [
    const {'1': 'command', '3': 1, '4': 1, '5': 14, '6': '.svg2iv.protobuf.PathNode.Command', '10': 'command'},
    const {'1': 'arguments', '3': 2, '4': 3, '5': 11, '6': '.svg2iv.protobuf.PathNode.Argument', '10': 'arguments'},
  ],
  '3': const [PathNode_Argument$json],
  '4': const [PathNode_Command$json],
};

const PathNode_Argument$json = const {
  '1': 'Argument',
  '2': const [
    const {'1': 'coordinate', '3': 1, '4': 1, '5': 2, '9': 0, '10': 'coordinate'},
    const {'1': 'flag', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'flag'},
  ],
  '8': const [
    const {'1': 'argument'},
  ],
};

const PathNode_Command$json = const {
  '1': 'Command',
  '2': const [
    const {'1': 'CLOSE', '2': 0},
    const {'1': 'MOVE_TO', '2': 1},
    const {'1': 'RELATIVE_MOVE_TO', '2': 2},
    const {'1': 'LINE_TO', '2': 3},
    const {'1': 'RELATIVE_LINE_TO', '2': 4},
    const {'1': 'HORIZONTAL_LINE_TO', '2': 5},
    const {'1': 'RELATIVE_HORIZONTAL_LINE_TO', '2': 6},
    const {'1': 'VERTICAL_LINE_TO', '2': 7},
    const {'1': 'RELATIVE_VERTICAL_LINE_TO', '2': 8},
    const {'1': 'CURVE_TO', '2': 9},
    const {'1': 'RELATIVE_CURVE_TO', '2': 10},
    const {'1': 'SMOOTH_CURVE_TO', '2': 11},
    const {'1': 'RELATIVE_SMOOTH_CURVE_TO', '2': 12},
    const {'1': 'QUADRATIC_BEZIER_CURVE_TO', '2': 13},
    const {'1': 'RELATIVE_QUADRATIC_BEZIER_CURVE_TO', '2': 14},
    const {'1': 'SMOOTH_QUADRATIC_BEZIER_CURVE_TO', '2': 15},
    const {'1': 'RELATIVE_SMOOTH_QUADRATIC_BEZIER_CURVE_TO', '2': 16},
    const {'1': 'ARC_TO', '2': 17},
    const {'1': 'RELATIVE_ARC_TO', '2': 18},
  ],
};

const Brush$json = const {
  '1': 'Brush',
  '2': const [
    const {'1': 'solid_color', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'solidColor'},
    const {'1': 'linear_gradient', '3': 2, '4': 1, '5': 11, '6': '.svg2iv.protobuf.Gradient', '9': 0, '10': 'linearGradient'},
    const {'1': 'radial_gradient', '3': 3, '4': 1, '5': 11, '6': '.svg2iv.protobuf.Gradient', '9': 0, '10': 'radialGradient'},
  ],
  '8': const [
    const {'1': 'solid_color_or_gradient'},
  ],
};

const Gradient$json = const {
  '1': 'Gradient',
  '2': const [
    const {'1': 'colors', '3': 1, '4': 3, '5': 13, '10': 'colors'},
    const {'1': 'stops', '3': 2, '4': 3, '5': 2, '10': 'stops'},
    const {'1': 'start_x', '3': 3, '4': 1, '5': 2, '10': 'startX'},
    const {'1': 'start_y', '3': 4, '4': 1, '5': 2, '10': 'startY'},
    const {'1': 'end_x', '3': 5, '4': 1, '5': 2, '10': 'endX'},
    const {'1': 'end_y', '3': 6, '4': 1, '5': 2, '10': 'endY'},
    const {'1': 'center_x', '3': 7, '4': 1, '5': 2, '10': 'centerX'},
    const {'1': 'center_y', '3': 8, '4': 1, '5': 2, '10': 'centerY'},
    const {'1': 'radius', '3': 9, '4': 1, '5': 2, '10': 'radius'},
    const {'1': 'tile_mode', '3': 10, '4': 1, '5': 14, '6': '.svg2iv.protobuf.Gradient.TileMode', '10': 'tileMode'},
  ],
  '4': const [Gradient_TileMode$json],
};

const Gradient_TileMode$json = const {
  '1': 'TileMode',
  '2': const [
    const {'1': 'CLAMP', '2': 0},
    const {'1': 'REPEATED', '2': 1},
    const {'1': 'MIRROR', '2': 2},
  ],
};

