//
//  Generated code. Do not modify.
//  source: image_vector.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use nullDescriptor instead')
const Null$json = const {
  '1': 'Null',
  '2': const [
    const {'1': 'NOTHING', '2': 0},
  ],
};

/// Descriptor for `Null`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nullDescriptor = $convert.base64Decode('CgROdWxsEgsKB05PVEhJTkcQAA==');
@$core.Deprecated('Use blendModeDescriptor instead')
const BlendMode$json = const {
  '1': 'BlendMode',
  '2': const [
    const {'1': 'SRC_OVER', '2': 0},
    const {'1': 'SRC_IN', '2': 1},
    const {'1': 'SRC_ATOP', '2': 2},
    const {'1': 'MODULATE', '2': 3},
    const {'1': 'SCREEN', '2': 4},
    const {'1': 'PLUS', '2': 5},
  ],
};

/// Descriptor for `BlendMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List blendModeDescriptor = $convert.base64Decode('CglCbGVuZE1vZGUSDAoIU1JDX09WRVIQABIKCgZTUkNfSU4QARIMCghTUkNfQVRPUBACEgwKCE1PRFVMQVRFEAMSCgoGU0NSRUVOEAQSCAoEUExVUxAF');
@$core.Deprecated('Use imageVectorCollectionDescriptor instead')
const ImageVectorCollection$json = const {
  '1': 'ImageVectorCollection',
  '2': const [
    const {'1': 'nullable_image_vectors', '3': 1, '4': 3, '5': 11, '6': '.svg2iv.protobuf.NullableImageVector', '10': 'nullableImageVectors'},
  ],
};

/// Descriptor for `ImageVectorCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageVectorCollectionDescriptor = $convert.base64Decode('ChVJbWFnZVZlY3RvckNvbGxlY3Rpb24SWgoWbnVsbGFibGVfaW1hZ2VfdmVjdG9ycxgBIAMoCzIkLnN2ZzJpdi5wcm90b2J1Zi5OdWxsYWJsZUltYWdlVmVjdG9yUhRudWxsYWJsZUltYWdlVmVjdG9ycw==');
@$core.Deprecated('Use nullableImageVectorDescriptor instead')
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

/// Descriptor for `NullableImageVector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nullableImageVectorDescriptor = $convert.base64Decode('ChNOdWxsYWJsZUltYWdlVmVjdG9yEjQKBXZhbHVlGAEgASgLMhwuc3ZnMml2LnByb3RvYnVmLkltYWdlVmVjdG9ySABSBXZhbHVlEjEKB25vdGhpbmcYAiABKA4yFS5zdmcyaXYucHJvdG9idWYuTnVsbEgAUgdub3RoaW5nQhIKEHZhbHVlX29yX25vdGhpbmc=');
@$core.Deprecated('Use imageVectorDescriptor instead')
const ImageVector$json = const {
  '1': 'ImageVector',
  '2': const [
    const {'1': 'nodes', '3': 1, '4': 3, '5': 11, '6': '.svg2iv.protobuf.VectorNode', '10': 'nodes'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'viewport_width', '3': 3, '4': 1, '5': 2, '10': 'viewportWidth'},
    const {'1': 'viewport_height', '3': 4, '4': 1, '5': 2, '10': 'viewportHeight'},
    const {'1': 'width', '3': 5, '4': 1, '5': 2, '10': 'width'},
    const {'1': 'height', '3': 6, '4': 1, '5': 2, '10': 'height'},
    const {'1': 'tint_color', '3': 7, '4': 1, '5': 13, '10': 'tintColor'},
    const {'1': 'tint_blend_mode', '3': 8, '4': 1, '5': 14, '6': '.svg2iv.protobuf.BlendMode', '10': 'tintBlendMode'},
  ],
};

/// Descriptor for `ImageVector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageVectorDescriptor = $convert.base64Decode('CgtJbWFnZVZlY3RvchIxCgVub2RlcxgBIAMoCzIbLnN2ZzJpdi5wcm90b2J1Zi5WZWN0b3JOb2RlUgVub2RlcxISCgRuYW1lGAIgASgJUgRuYW1lEiUKDnZpZXdwb3J0X3dpZHRoGAMgASgCUg12aWV3cG9ydFdpZHRoEicKD3ZpZXdwb3J0X2hlaWdodBgEIAEoAlIOdmlld3BvcnRIZWlnaHQSFAoFd2lkdGgYBSABKAJSBXdpZHRoEhYKBmhlaWdodBgGIAEoAlIGaGVpZ2h0Eh0KCnRpbnRfY29sb3IYByABKA1SCXRpbnRDb2xvchJCCg90aW50X2JsZW5kX21vZGUYCCABKA4yGi5zdmcyaXYucHJvdG9idWYuQmxlbmRNb2RlUg10aW50QmxlbmRNb2Rl');
@$core.Deprecated('Use vectorNodeDescriptor instead')
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

/// Descriptor for `VectorNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorNodeDescriptor = $convert.base64Decode('CgpWZWN0b3JOb2RlEjQKBWdyb3VwGAEgASgLMhwuc3ZnMml2LnByb3RvYnVmLlZlY3Rvckdyb3VwSABSBWdyb3VwEjEKBHBhdGgYAiABKAsyGy5zdmcyaXYucHJvdG9idWYuVmVjdG9yUGF0aEgAUgRwYXRoQgYKBG5vZGU=');
@$core.Deprecated('Use vectorGroupDescriptor instead')
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

/// Descriptor for `VectorGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorGroupDescriptor = $convert.base64Decode('CgtWZWN0b3JHcm91cBIxCgVub2RlcxgBIAMoCzIbLnN2ZzJpdi5wcm90b2J1Zi5WZWN0b3JOb2RlUgVub2RlcxIOCgJpZBgCIAEoCVICaWQSGgoIcm90YXRpb24YAyABKAJSCHJvdGF0aW9uEhcKB3Bpdm90X3gYBCABKAJSBnBpdm90WBIXCgdwaXZvdF95GAUgASgCUgZwaXZvdFkSFwoHc2NhbGVfeBgGIAEoAlIGc2NhbGVYEhcKB3NjYWxlX3kYCiABKAJSBnNjYWxlWRIjCg10cmFuc2xhdGlvbl94GAcgASgCUgx0cmFuc2xhdGlvblgSIwoNdHJhbnNsYXRpb25feRgIIAEoAlIMdHJhbnNsYXRpb25ZEj8KDmNsaXBfcGF0aF9kYXRhGAkgAygLMhkuc3ZnMml2LnByb3RvYnVmLlBhdGhOb2RlUgxjbGlwUGF0aERhdGE=');
@$core.Deprecated('Use vectorPathDescriptor instead')
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
    const {'1': 'trim_path_start', '3': 12, '4': 1, '5': 2, '10': 'trimPathStart'},
    const {'1': 'trim_path_end', '3': 13, '4': 1, '5': 2, '10': 'trimPathEnd'},
    const {'1': 'trim_path_offset', '3': 14, '4': 1, '5': 2, '10': 'trimPathOffset'},
  ],
  '4': const [VectorPath_StrokeCap$json, VectorPath_StrokeJoin$json, VectorPath_FillType$json],
};

@$core.Deprecated('Use vectorPathDescriptor instead')
const VectorPath_StrokeCap$json = const {
  '1': 'StrokeCap',
  '2': const [
    const {'1': 'CAP_BUTT', '2': 0},
    const {'1': 'CAP_ROUND', '2': 1},
    const {'1': 'CAP_SQUARE', '2': 2},
  ],
};

@$core.Deprecated('Use vectorPathDescriptor instead')
const VectorPath_StrokeJoin$json = const {
  '1': 'StrokeJoin',
  '2': const [
    const {'1': 'JOIN_MITER', '2': 0},
    const {'1': 'JOIN_ROUND', '2': 1},
    const {'1': 'JOIN_BEVEL', '2': 2},
  ],
};

@$core.Deprecated('Use vectorPathDescriptor instead')
const VectorPath_FillType$json = const {
  '1': 'FillType',
  '2': const [
    const {'1': 'NON_ZERO', '2': 0},
    const {'1': 'EVEN_ODD', '2': 1},
  ],
};

/// Descriptor for `VectorPath`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorPathDescriptor = $convert.base64Decode('CgpWZWN0b3JQYXRoEjgKCnBhdGhfbm9kZXMYASADKAsyGS5zdmcyaXYucHJvdG9idWYuUGF0aE5vZGVSCXBhdGhOb2RlcxIOCgJpZBgCIAEoCVICaWQSKgoEZmlsbBgDIAEoCzIWLnN2ZzJpdi5wcm90b2J1Zi5CcnVzaFIEZmlsbBIdCgpmaWxsX2FscGhhGAQgASgCUglmaWxsQWxwaGESLgoGc3Ryb2tlGAUgASgLMhYuc3ZnMml2LnByb3RvYnVmLkJydXNoUgZzdHJva2USIQoMc3Ryb2tlX2FscGhhGAYgASgCUgtzdHJva2VBbHBoYRIqChFzdHJva2VfbGluZV93aWR0aBgHIAEoAlIPc3Ryb2tlTGluZVdpZHRoEk0KD3N0cm9rZV9saW5lX2NhcBgJIAEoDjIlLnN2ZzJpdi5wcm90b2J1Zi5WZWN0b3JQYXRoLlN0cm9rZUNhcFINc3Ryb2tlTGluZUNhcBJQChBzdHJva2VfbGluZV9qb2luGAogASgOMiYuc3ZnMml2LnByb3RvYnVmLlZlY3RvclBhdGguU3Ryb2tlSm9pblIOc3Ryb2tlTGluZUpvaW4SKgoRc3Ryb2tlX2xpbmVfbWl0ZXIYCyABKAJSD3N0cm9rZUxpbmVNaXRlchJBCglmaWxsX3R5cGUYCCABKA4yJC5zdmcyaXYucHJvdG9idWYuVmVjdG9yUGF0aC5GaWxsVHlwZVIIZmlsbFR5cGUSJgoPdHJpbV9wYXRoX3N0YXJ0GAwgASgCUg10cmltUGF0aFN0YXJ0EiIKDXRyaW1fcGF0aF9lbmQYDSABKAJSC3RyaW1QYXRoRW5kEigKEHRyaW1fcGF0aF9vZmZzZXQYDiABKAJSDnRyaW1QYXRoT2Zmc2V0IjgKCVN0cm9rZUNhcBIMCghDQVBfQlVUVBAAEg0KCUNBUF9ST1VORBABEg4KCkNBUF9TUVVBUkUQAiI8CgpTdHJva2VKb2luEg4KCkpPSU5fTUlURVIQABIOCgpKT0lOX1JPVU5EEAESDgoKSk9JTl9CRVZFTBACIiYKCEZpbGxUeXBlEgwKCE5PTl9aRVJPEAASDAoIRVZFTl9PREQQAQ==');
@$core.Deprecated('Use pathNodeDescriptor instead')
const PathNode$json = const {
  '1': 'PathNode',
  '2': const [
    const {'1': 'command', '3': 1, '4': 1, '5': 14, '6': '.svg2iv.protobuf.PathNode.Command', '10': 'command'},
    const {'1': 'arguments', '3': 2, '4': 3, '5': 11, '6': '.svg2iv.protobuf.PathNode.Argument', '10': 'arguments'},
  ],
  '3': const [PathNode_Argument$json],
  '4': const [PathNode_Command$json],
};

@$core.Deprecated('Use pathNodeDescriptor instead')
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

@$core.Deprecated('Use pathNodeDescriptor instead')
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

/// Descriptor for `PathNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pathNodeDescriptor = $convert.base64Decode('CghQYXRoTm9kZRI7Cgdjb21tYW5kGAEgASgOMiEuc3ZnMml2LnByb3RvYnVmLlBhdGhOb2RlLkNvbW1hbmRSB2NvbW1hbmQSQAoJYXJndW1lbnRzGAIgAygLMiIuc3ZnMml2LnByb3RvYnVmLlBhdGhOb2RlLkFyZ3VtZW50Uglhcmd1bWVudHMaTgoIQXJndW1lbnQSIAoKY29vcmRpbmF0ZRgBIAEoAkgAUgpjb29yZGluYXRlEhQKBGZsYWcYAiABKAhIAFIEZmxhZ0IKCghhcmd1bWVudCLdAwoHQ29tbWFuZBIJCgVDTE9TRRAAEgsKB01PVkVfVE8QARIUChBSRUxBVElWRV9NT1ZFX1RPEAISCwoHTElORV9UTxADEhQKEFJFTEFUSVZFX0xJTkVfVE8QBBIWChJIT1JJWk9OVEFMX0xJTkVfVE8QBRIfChtSRUxBVElWRV9IT1JJWk9OVEFMX0xJTkVfVE8QBhIUChBWRVJUSUNBTF9MSU5FX1RPEAcSHQoZUkVMQVRJVkVfVkVSVElDQUxfTElORV9UTxAIEgwKCENVUlZFX1RPEAkSFQoRUkVMQVRJVkVfQ1VSVkVfVE8QChITCg9TTU9PVEhfQ1VSVkVfVE8QCxIcChhSRUxBVElWRV9TTU9PVEhfQ1VSVkVfVE8QDBIdChlRVUFEUkFUSUNfQkVaSUVSX0NVUlZFX1RPEA0SJgoiUkVMQVRJVkVfUVVBRFJBVElDX0JFWklFUl9DVVJWRV9UTxAOEiQKIFNNT09USF9RVUFEUkFUSUNfQkVaSUVSX0NVUlZFX1RPEA8SLQopUkVMQVRJVkVfU01PT1RIX1FVQURSQVRJQ19CRVpJRVJfQ1VSVkVfVE8QEBIKCgZBUkNfVE8QERITCg9SRUxBVElWRV9BUkNfVE8QEg==');
@$core.Deprecated('Use brushDescriptor instead')
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

/// Descriptor for `Brush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List brushDescriptor = $convert.base64Decode('CgVCcnVzaBIhCgtzb2xpZF9jb2xvchgBIAEoDUgAUgpzb2xpZENvbG9yEkQKD2xpbmVhcl9ncmFkaWVudBgCIAEoCzIZLnN2ZzJpdi5wcm90b2J1Zi5HcmFkaWVudEgAUg5saW5lYXJHcmFkaWVudBJECg9yYWRpYWxfZ3JhZGllbnQYAyABKAsyGS5zdmcyaXYucHJvdG9idWYuR3JhZGllbnRIAFIOcmFkaWFsR3JhZGllbnRCGQoXc29saWRfY29sb3Jfb3JfZ3JhZGllbnQ=');
@$core.Deprecated('Use gradientDescriptor instead')
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

@$core.Deprecated('Use gradientDescriptor instead')
const Gradient_TileMode$json = const {
  '1': 'TileMode',
  '2': const [
    const {'1': 'CLAMP', '2': 0},
    const {'1': 'REPEATED', '2': 1},
    const {'1': 'MIRROR', '2': 2},
  ],
};

/// Descriptor for `Gradient`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gradientDescriptor = $convert.base64Decode('CghHcmFkaWVudBIWCgZjb2xvcnMYASADKA1SBmNvbG9ycxIUCgVzdG9wcxgCIAMoAlIFc3RvcHMSFwoHc3RhcnRfeBgDIAEoAlIGc3RhcnRYEhcKB3N0YXJ0X3kYBCABKAJSBnN0YXJ0WRITCgVlbmRfeBgFIAEoAlIEZW5kWBITCgVlbmRfeRgGIAEoAlIEZW5kWRIZCghjZW50ZXJfeBgHIAEoAlIHY2VudGVyWBIZCghjZW50ZXJfeRgIIAEoAlIHY2VudGVyWRIWCgZyYWRpdXMYCSABKAJSBnJhZGl1cxI/Cgl0aWxlX21vZGUYCiABKA4yIi5zdmcyaXYucHJvdG9idWYuR3JhZGllbnQuVGlsZU1vZGVSCHRpbGVNb2RlIi8KCFRpbGVNb2RlEgkKBUNMQU1QEAASDAoIUkVQRUFURUQQARIKCgZNSVJST1IQAg==');
