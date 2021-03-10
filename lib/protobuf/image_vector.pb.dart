//
//  Generated code. Do not modify.
//  source: image_vector.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'image_vector.pbenum.dart';

export 'image_vector.pbenum.dart';

class ImageVectorCollection extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ImageVectorCollection', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..pc<NullableImageVector>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nullableImageVectors', $pb.PbFieldType.PM, subBuilder: NullableImageVector.create)
    ..hasRequiredFields = false
  ;

  ImageVectorCollection._() : super();
  factory ImageVectorCollection({
    $core.Iterable<NullableImageVector>? nullableImageVectors,
  }) {
    final _result = create();
    if (nullableImageVectors != null) {
      _result.nullableImageVectors.addAll(nullableImageVectors);
    }
    return _result;
  }
  factory ImageVectorCollection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImageVectorCollection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImageVectorCollection clone() => ImageVectorCollection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImageVectorCollection copyWith(void Function(ImageVectorCollection) updates) => super.copyWith((message) => updates(message as ImageVectorCollection)) as ImageVectorCollection; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ImageVectorCollection create() => ImageVectorCollection._();
  ImageVectorCollection createEmptyInstance() => create();
  static $pb.PbList<ImageVectorCollection> createRepeated() => $pb.PbList<ImageVectorCollection>();
  @$core.pragma('dart2js:noInline')
  static ImageVectorCollection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageVectorCollection>(create);
  static ImageVectorCollection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NullableImageVector> get nullableImageVectors => $_getList(0);
}

enum NullableImageVector_ValueOrNothing {
  value,
  nothing,
  notSet
}

class NullableImageVector extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, NullableImageVector_ValueOrNothing> _NullableImageVector_ValueOrNothingByTag = {
    1 : NullableImageVector_ValueOrNothing.value,
    2 : NullableImageVector_ValueOrNothing.nothing,
    0 : NullableImageVector_ValueOrNothing.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NullableImageVector', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ImageVector>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value', subBuilder: ImageVector.create)
    ..e<Null>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nothing', $pb.PbFieldType.OE, defaultOrMaker: Null.NOTHING, valueOf: Null.valueOf, enumValues: Null.values)
    ..hasRequiredFields = false
  ;

  NullableImageVector._() : super();
  factory NullableImageVector({
    ImageVector? value,
    Null? nothing,
  }) {
    final _result = create();
    if (value != null) {
      _result.value = value;
    }
    if (nothing != null) {
      _result.nothing = nothing;
    }
    return _result;
  }
  factory NullableImageVector.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NullableImageVector.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NullableImageVector clone() => NullableImageVector()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NullableImageVector copyWith(void Function(NullableImageVector) updates) => super.copyWith((message) => updates(message as NullableImageVector)) as NullableImageVector; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NullableImageVector create() => NullableImageVector._();
  NullableImageVector createEmptyInstance() => create();
  static $pb.PbList<NullableImageVector> createRepeated() => $pb.PbList<NullableImageVector>();
  @$core.pragma('dart2js:noInline')
  static NullableImageVector getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NullableImageVector>(create);
  static NullableImageVector? _defaultInstance;

  NullableImageVector_ValueOrNothing whichValueOrNothing() => _NullableImageVector_ValueOrNothingByTag[$_whichOneof(0)]!;
  void clearValueOrNothing() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ImageVector get value => $_getN(0);
  @$pb.TagNumber(1)
  set value(ImageVector v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
  @$pb.TagNumber(1)
  ImageVector ensureValue() => $_ensure(0);

  @$pb.TagNumber(2)
  Null get nothing => $_getN(1);
  @$pb.TagNumber(2)
  set nothing(Null v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNothing() => $_has(1);
  @$pb.TagNumber(2)
  void clearNothing() => clearField(2);
}

class ImageVector extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ImageVector', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..pc<VectorNode>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nodes', $pb.PbFieldType.PM, subBuilder: VectorNode.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'viewportWidth', $pb.PbFieldType.OF)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'viewportHeight', $pb.PbFieldType.OF)
    ..a<$core.double>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'width', $pb.PbFieldType.OF)
    ..a<$core.double>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'height', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  ImageVector._() : super();
  factory ImageVector({
    $core.Iterable<VectorNode>? nodes,
    $core.String? name,
    $core.double? viewportWidth,
    $core.double? viewportHeight,
    $core.double? width,
    $core.double? height,
  }) {
    final _result = create();
    if (nodes != null) {
      _result.nodes.addAll(nodes);
    }
    if (name != null) {
      _result.name = name;
    }
    if (viewportWidth != null) {
      _result.viewportWidth = viewportWidth;
    }
    if (viewportHeight != null) {
      _result.viewportHeight = viewportHeight;
    }
    if (width != null) {
      _result.width = width;
    }
    if (height != null) {
      _result.height = height;
    }
    return _result;
  }
  factory ImageVector.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImageVector.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImageVector clone() => ImageVector()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImageVector copyWith(void Function(ImageVector) updates) => super.copyWith((message) => updates(message as ImageVector)) as ImageVector; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ImageVector create() => ImageVector._();
  ImageVector createEmptyInstance() => create();
  static $pb.PbList<ImageVector> createRepeated() => $pb.PbList<ImageVector>();
  @$core.pragma('dart2js:noInline')
  static ImageVector getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageVector>(create);
  static ImageVector? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<VectorNode> get nodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get viewportWidth => $_getN(2);
  @$pb.TagNumber(3)
  set viewportWidth($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasViewportWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearViewportWidth() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get viewportHeight => $_getN(3);
  @$pb.TagNumber(4)
  set viewportHeight($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasViewportHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearViewportHeight() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get width => $_getN(4);
  @$pb.TagNumber(5)
  set width($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearWidth() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get height => $_getN(5);
  @$pb.TagNumber(6)
  set height($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeight() => clearField(6);
}

enum VectorNode_Node {
  group, 
  path, 
  notSet
}

class VectorNode extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, VectorNode_Node> _VectorNode_NodeByTag = {
    1 : VectorNode_Node.group,
    2 : VectorNode_Node.path,
    0 : VectorNode_Node.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VectorNode', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<VectorGroup>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'group', subBuilder: VectorGroup.create)
    ..aOM<VectorPath>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'path', subBuilder: VectorPath.create)
    ..hasRequiredFields = false
  ;

  VectorNode._() : super();
  factory VectorNode({
    VectorGroup? group,
    VectorPath? path,
  }) {
    final _result = create();
    if (group != null) {
      _result.group = group;
    }
    if (path != null) {
      _result.path = path;
    }
    return _result;
  }
  factory VectorNode.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VectorNode.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VectorNode clone() => VectorNode()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VectorNode copyWith(void Function(VectorNode) updates) => super.copyWith((message) => updates(message as VectorNode)) as VectorNode; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VectorNode create() => VectorNode._();
  VectorNode createEmptyInstance() => create();
  static $pb.PbList<VectorNode> createRepeated() => $pb.PbList<VectorNode>();
  @$core.pragma('dart2js:noInline')
  static VectorNode getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorNode>(create);
  static VectorNode? _defaultInstance;

  VectorNode_Node whichNode() => _VectorNode_NodeByTag[$_whichOneof(0)]!;
  void clearNode() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  VectorGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(VectorGroup v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  VectorGroup ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  VectorPath get path => $_getN(1);
  @$pb.TagNumber(2)
  set path(VectorPath v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => clearField(2);
  @$pb.TagNumber(2)
  VectorPath ensurePath() => $_ensure(1);
}

class VectorGroup extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VectorGroup', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..pc<VectorNode>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nodes', $pb.PbFieldType.PM, subBuilder: VectorNode.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'rotation', $pb.PbFieldType.OF)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pivotX', $pb.PbFieldType.OF)
    ..a<$core.double>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pivotY', $pb.PbFieldType.OF)
    ..a<$core.double>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'scaleX', $pb.PbFieldType.OF)
    ..a<$core.double>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'translationX', $pb.PbFieldType.OF)
    ..a<$core.double>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'translationY', $pb.PbFieldType.OF)
    ..pc<PathNode>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'clipPathData', $pb.PbFieldType.PM, subBuilder: PathNode.create)
    ..a<$core.double>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'scaleY', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  VectorGroup._() : super();
  factory VectorGroup({
    $core.Iterable<VectorNode>? nodes,
    $core.String? id,
    $core.double? rotation,
    $core.double? pivotX,
    $core.double? pivotY,
    $core.double? scaleX,
    $core.double? translationX,
    $core.double? translationY,
    $core.Iterable<PathNode>? clipPathData,
    $core.double? scaleY,
  }) {
    final _result = create();
    if (nodes != null) {
      _result.nodes.addAll(nodes);
    }
    if (id != null) {
      _result.id = id;
    }
    if (rotation != null) {
      _result.rotation = rotation;
    }
    if (pivotX != null) {
      _result.pivotX = pivotX;
    }
    if (pivotY != null) {
      _result.pivotY = pivotY;
    }
    if (scaleX != null) {
      _result.scaleX = scaleX;
    }
    if (translationX != null) {
      _result.translationX = translationX;
    }
    if (translationY != null) {
      _result.translationY = translationY;
    }
    if (clipPathData != null) {
      _result.clipPathData.addAll(clipPathData);
    }
    if (scaleY != null) {
      _result.scaleY = scaleY;
    }
    return _result;
  }
  factory VectorGroup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VectorGroup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VectorGroup clone() => VectorGroup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VectorGroup copyWith(void Function(VectorGroup) updates) => super.copyWith((message) => updates(message as VectorGroup)) as VectorGroup; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VectorGroup create() => VectorGroup._();
  VectorGroup createEmptyInstance() => create();
  static $pb.PbList<VectorGroup> createRepeated() => $pb.PbList<VectorGroup>();
  @$core.pragma('dart2js:noInline')
  static VectorGroup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorGroup>(create);
  static VectorGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<VectorNode> get nodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get rotation => $_getN(2);
  @$pb.TagNumber(3)
  set rotation($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRotation() => $_has(2);
  @$pb.TagNumber(3)
  void clearRotation() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get pivotX => $_getN(3);
  @$pb.TagNumber(4)
  set pivotX($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPivotX() => $_has(3);
  @$pb.TagNumber(4)
  void clearPivotX() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get pivotY => $_getN(4);
  @$pb.TagNumber(5)
  set pivotY($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPivotY() => $_has(4);
  @$pb.TagNumber(5)
  void clearPivotY() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get scaleX => $_getN(5);
  @$pb.TagNumber(6)
  set scaleX($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScaleX() => $_has(5);
  @$pb.TagNumber(6)
  void clearScaleX() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get translationX => $_getN(6);
  @$pb.TagNumber(7)
  set translationX($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTranslationX() => $_has(6);
  @$pb.TagNumber(7)
  void clearTranslationX() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get translationY => $_getN(7);
  @$pb.TagNumber(8)
  set translationY($core.double v) { $_setFloat(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTranslationY() => $_has(7);
  @$pb.TagNumber(8)
  void clearTranslationY() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<PathNode> get clipPathData => $_getList(8);

  @$pb.TagNumber(10)
  $core.double get scaleY => $_getN(9);
  @$pb.TagNumber(10)
  set scaleY($core.double v) { $_setFloat(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasScaleY() => $_has(9);
  @$pb.TagNumber(10)
  void clearScaleY() => clearField(10);
}

class VectorPath extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'VectorPath', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..pc<PathNode>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pathNodes', $pb.PbFieldType.PM, subBuilder: PathNode.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOM<Brush>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fill', subBuilder: Brush.create)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fillAlpha', $pb.PbFieldType.OF)
    ..aOM<Brush>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'stroke', subBuilder: Brush.create)
    ..a<$core.double>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'strokeAlpha', $pb.PbFieldType.OF)
    ..a<$core.double>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'strokeLineWidth', $pb.PbFieldType.OF)
    ..e<VectorPath_FillType>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fillType', $pb.PbFieldType.OE, defaultOrMaker: VectorPath_FillType.NON_ZERO, valueOf: VectorPath_FillType.valueOf, enumValues: VectorPath_FillType.values)
    ..e<VectorPath_StrokeCap>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'strokeLineCap', $pb.PbFieldType.OE, defaultOrMaker: VectorPath_StrokeCap.CAP_BUTT, valueOf: VectorPath_StrokeCap.valueOf, enumValues: VectorPath_StrokeCap.values)
    ..e<VectorPath_StrokeJoin>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'strokeLineJoin', $pb.PbFieldType.OE, defaultOrMaker: VectorPath_StrokeJoin.JOIN_MITER, valueOf: VectorPath_StrokeJoin.valueOf, enumValues: VectorPath_StrokeJoin.values)
    ..a<$core.double>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'strokeLineMiter', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  VectorPath._() : super();
  factory VectorPath({
    $core.Iterable<PathNode>? pathNodes,
    $core.String? id,
    Brush? fill,
    $core.double? fillAlpha,
    Brush? stroke,
    $core.double? strokeAlpha,
    $core.double? strokeLineWidth,
    VectorPath_FillType? fillType,
    VectorPath_StrokeCap? strokeLineCap,
    VectorPath_StrokeJoin? strokeLineJoin,
    $core.double? strokeLineMiter,
  }) {
    final _result = create();
    if (pathNodes != null) {
      _result.pathNodes.addAll(pathNodes);
    }
    if (id != null) {
      _result.id = id;
    }
    if (fill != null) {
      _result.fill = fill;
    }
    if (fillAlpha != null) {
      _result.fillAlpha = fillAlpha;
    }
    if (stroke != null) {
      _result.stroke = stroke;
    }
    if (strokeAlpha != null) {
      _result.strokeAlpha = strokeAlpha;
    }
    if (strokeLineWidth != null) {
      _result.strokeLineWidth = strokeLineWidth;
    }
    if (fillType != null) {
      _result.fillType = fillType;
    }
    if (strokeLineCap != null) {
      _result.strokeLineCap = strokeLineCap;
    }
    if (strokeLineJoin != null) {
      _result.strokeLineJoin = strokeLineJoin;
    }
    if (strokeLineMiter != null) {
      _result.strokeLineMiter = strokeLineMiter;
    }
    return _result;
  }
  factory VectorPath.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VectorPath.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VectorPath clone() => VectorPath()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VectorPath copyWith(void Function(VectorPath) updates) => super.copyWith((message) => updates(message as VectorPath)) as VectorPath; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VectorPath create() => VectorPath._();
  VectorPath createEmptyInstance() => create();
  static $pb.PbList<VectorPath> createRepeated() => $pb.PbList<VectorPath>();
  @$core.pragma('dart2js:noInline')
  static VectorPath getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorPath>(create);
  static VectorPath? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PathNode> get pathNodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

  @$pb.TagNumber(3)
  Brush get fill => $_getN(2);
  @$pb.TagNumber(3)
  set fill(Brush v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasFill() => $_has(2);
  @$pb.TagNumber(3)
  void clearFill() => clearField(3);
  @$pb.TagNumber(3)
  Brush ensureFill() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.double get fillAlpha => $_getN(3);
  @$pb.TagNumber(4)
  set fillAlpha($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFillAlpha() => $_has(3);
  @$pb.TagNumber(4)
  void clearFillAlpha() => clearField(4);

  @$pb.TagNumber(5)
  Brush get stroke => $_getN(4);
  @$pb.TagNumber(5)
  set stroke(Brush v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStroke() => $_has(4);
  @$pb.TagNumber(5)
  void clearStroke() => clearField(5);
  @$pb.TagNumber(5)
  Brush ensureStroke() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get strokeAlpha => $_getN(5);
  @$pb.TagNumber(6)
  set strokeAlpha($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStrokeAlpha() => $_has(5);
  @$pb.TagNumber(6)
  void clearStrokeAlpha() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get strokeLineWidth => $_getN(6);
  @$pb.TagNumber(7)
  set strokeLineWidth($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStrokeLineWidth() => $_has(6);
  @$pb.TagNumber(7)
  void clearStrokeLineWidth() => clearField(7);

  @$pb.TagNumber(8)
  VectorPath_FillType get fillType => $_getN(7);
  @$pb.TagNumber(8)
  set fillType(VectorPath_FillType v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFillType() => $_has(7);
  @$pb.TagNumber(8)
  void clearFillType() => clearField(8);

  @$pb.TagNumber(9)
  VectorPath_StrokeCap get strokeLineCap => $_getN(8);
  @$pb.TagNumber(9)
  set strokeLineCap(VectorPath_StrokeCap v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStrokeLineCap() => $_has(8);
  @$pb.TagNumber(9)
  void clearStrokeLineCap() => clearField(9);

  @$pb.TagNumber(10)
  VectorPath_StrokeJoin get strokeLineJoin => $_getN(9);
  @$pb.TagNumber(10)
  set strokeLineJoin(VectorPath_StrokeJoin v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasStrokeLineJoin() => $_has(9);
  @$pb.TagNumber(10)
  void clearStrokeLineJoin() => clearField(10);

  @$pb.TagNumber(11)
  $core.double get strokeLineMiter => $_getN(10);
  @$pb.TagNumber(11)
  set strokeLineMiter($core.double v) { $_setFloat(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasStrokeLineMiter() => $_has(10);
  @$pb.TagNumber(11)
  void clearStrokeLineMiter() => clearField(11);
}

enum PathNode_Argument_Argument {
  coordinate, 
  flag, 
  notSet
}

class PathNode_Argument extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, PathNode_Argument_Argument> _PathNode_Argument_ArgumentByTag = {
    1 : PathNode_Argument_Argument.coordinate,
    2 : PathNode_Argument_Argument.flag,
    0 : PathNode_Argument_Argument.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PathNode.Argument', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..a<$core.double>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'coordinate', $pb.PbFieldType.OF)
    ..aOB(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'flag')
    ..hasRequiredFields = false
  ;

  PathNode_Argument._() : super();
  factory PathNode_Argument({
    $core.double? coordinate,
    $core.bool? flag,
  }) {
    final _result = create();
    if (coordinate != null) {
      _result.coordinate = coordinate;
    }
    if (flag != null) {
      _result.flag = flag;
    }
    return _result;
  }
  factory PathNode_Argument.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PathNode_Argument.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PathNode_Argument clone() => PathNode_Argument()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PathNode_Argument copyWith(void Function(PathNode_Argument) updates) => super.copyWith((message) => updates(message as PathNode_Argument)) as PathNode_Argument; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PathNode_Argument create() => PathNode_Argument._();
  PathNode_Argument createEmptyInstance() => create();
  static $pb.PbList<PathNode_Argument> createRepeated() => $pb.PbList<PathNode_Argument>();
  @$core.pragma('dart2js:noInline')
  static PathNode_Argument getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PathNode_Argument>(create);
  static PathNode_Argument? _defaultInstance;

  PathNode_Argument_Argument whichArgument() => _PathNode_Argument_ArgumentByTag[$_whichOneof(0)]!;
  void clearArgument() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.double get coordinate => $_getN(0);
  @$pb.TagNumber(1)
  set coordinate($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCoordinate() => $_has(0);
  @$pb.TagNumber(1)
  void clearCoordinate() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get flag => $_getBF(1);
  @$pb.TagNumber(2)
  set flag($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFlag() => $_has(1);
  @$pb.TagNumber(2)
  void clearFlag() => clearField(2);
}

class PathNode extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PathNode', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..e<PathNode_Command>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'command', $pb.PbFieldType.OE, defaultOrMaker: PathNode_Command.CLOSE, valueOf: PathNode_Command.valueOf, enumValues: PathNode_Command.values)
    ..pc<PathNode_Argument>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'arguments', $pb.PbFieldType.PM, subBuilder: PathNode_Argument.create)
    ..hasRequiredFields = false
  ;

  PathNode._() : super();
  factory PathNode({
    PathNode_Command? command,
    $core.Iterable<PathNode_Argument>? arguments,
  }) {
    final _result = create();
    if (command != null) {
      _result.command = command;
    }
    if (arguments != null) {
      _result.arguments.addAll(arguments);
    }
    return _result;
  }
  factory PathNode.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PathNode.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PathNode clone() => PathNode()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PathNode copyWith(void Function(PathNode) updates) => super.copyWith((message) => updates(message as PathNode)) as PathNode; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PathNode create() => PathNode._();
  PathNode createEmptyInstance() => create();
  static $pb.PbList<PathNode> createRepeated() => $pb.PbList<PathNode>();
  @$core.pragma('dart2js:noInline')
  static PathNode getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PathNode>(create);
  static PathNode? _defaultInstance;

  @$pb.TagNumber(1)
  PathNode_Command get command => $_getN(0);
  @$pb.TagNumber(1)
  set command(PathNode_Command v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommand() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommand() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<PathNode_Argument> get arguments => $_getList(1);
}

enum Brush_SolidColorOrGradient {
  solidColor, 
  linearGradient, 
  radialGradient, 
  notSet
}

class Brush extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, Brush_SolidColorOrGradient> _Brush_SolidColorOrGradientByTag = {
    1 : Brush_SolidColorOrGradient.solidColor,
    2 : Brush_SolidColorOrGradient.linearGradient,
    3 : Brush_SolidColorOrGradient.radialGradient,
    0 : Brush_SolidColorOrGradient.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Brush', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'solidColor', $pb.PbFieldType.OU3)
    ..aOM<Gradient>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'linearGradient', subBuilder: Gradient.create)
    ..aOM<Gradient>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'radialGradient', subBuilder: Gradient.create)
    ..hasRequiredFields = false
  ;

  Brush._() : super();
  factory Brush({
    $core.int? solidColor,
    Gradient? linearGradient,
    Gradient? radialGradient,
  }) {
    final _result = create();
    if (solidColor != null) {
      _result.solidColor = solidColor;
    }
    if (linearGradient != null) {
      _result.linearGradient = linearGradient;
    }
    if (radialGradient != null) {
      _result.radialGradient = radialGradient;
    }
    return _result;
  }
  factory Brush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Brush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Brush clone() => Brush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Brush copyWith(void Function(Brush) updates) => super.copyWith((message) => updates(message as Brush)) as Brush; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Brush create() => Brush._();
  Brush createEmptyInstance() => create();
  static $pb.PbList<Brush> createRepeated() => $pb.PbList<Brush>();
  @$core.pragma('dart2js:noInline')
  static Brush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Brush>(create);
  static Brush? _defaultInstance;

  Brush_SolidColorOrGradient whichSolidColorOrGradient() => _Brush_SolidColorOrGradientByTag[$_whichOneof(0)]!;
  void clearSolidColorOrGradient() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get solidColor => $_getIZ(0);
  @$pb.TagNumber(1)
  set solidColor($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSolidColor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSolidColor() => clearField(1);

  @$pb.TagNumber(2)
  Gradient get linearGradient => $_getN(1);
  @$pb.TagNumber(2)
  set linearGradient(Gradient v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLinearGradient() => $_has(1);
  @$pb.TagNumber(2)
  void clearLinearGradient() => clearField(2);
  @$pb.TagNumber(2)
  Gradient ensureLinearGradient() => $_ensure(1);

  @$pb.TagNumber(3)
  Gradient get radialGradient => $_getN(2);
  @$pb.TagNumber(3)
  set radialGradient(Gradient v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRadialGradient() => $_has(2);
  @$pb.TagNumber(3)
  void clearRadialGradient() => clearField(3);
  @$pb.TagNumber(3)
  Gradient ensureRadialGradient() => $_ensure(2);
}

class Gradient extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Gradient', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'svg2iv.protobuf'), createEmptyInstance: create)
    ..p<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'colors', $pb.PbFieldType.PU3)
    ..p<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'stops', $pb.PbFieldType.PF)
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startX', $pb.PbFieldType.OF)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startY', $pb.PbFieldType.OF)
    ..a<$core.double>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endX', $pb.PbFieldType.OF)
    ..a<$core.double>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endY', $pb.PbFieldType.OF)
    ..a<$core.double>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'centerX', $pb.PbFieldType.OF)
    ..a<$core.double>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'centerY', $pb.PbFieldType.OF)
    ..a<$core.double>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'radius', $pb.PbFieldType.OF)
    ..e<Gradient_TileMode>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tileMode', $pb.PbFieldType.OE, defaultOrMaker: Gradient_TileMode.CLAMP, valueOf: Gradient_TileMode.valueOf, enumValues: Gradient_TileMode.values)
    ..hasRequiredFields = false
  ;

  Gradient._() : super();
  factory Gradient({
    $core.Iterable<$core.int>? colors,
    $core.Iterable<$core.double>? stops,
    $core.double? startX,
    $core.double? startY,
    $core.double? endX,
    $core.double? endY,
    $core.double? centerX,
    $core.double? centerY,
    $core.double? radius,
    Gradient_TileMode? tileMode,
  }) {
    final _result = create();
    if (colors != null) {
      _result.colors.addAll(colors);
    }
    if (stops != null) {
      _result.stops.addAll(stops);
    }
    if (startX != null) {
      _result.startX = startX;
    }
    if (startY != null) {
      _result.startY = startY;
    }
    if (endX != null) {
      _result.endX = endX;
    }
    if (endY != null) {
      _result.endY = endY;
    }
    if (centerX != null) {
      _result.centerX = centerX;
    }
    if (centerY != null) {
      _result.centerY = centerY;
    }
    if (radius != null) {
      _result.radius = radius;
    }
    if (tileMode != null) {
      _result.tileMode = tileMode;
    }
    return _result;
  }
  factory Gradient.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Gradient.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Gradient clone() => Gradient()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Gradient copyWith(void Function(Gradient) updates) => super.copyWith((message) => updates(message as Gradient)) as Gradient; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Gradient create() => Gradient._();
  Gradient createEmptyInstance() => create();
  static $pb.PbList<Gradient> createRepeated() => $pb.PbList<Gradient>();
  @$core.pragma('dart2js:noInline')
  static Gradient getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Gradient>(create);
  static Gradient? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get colors => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.double> get stops => $_getList(1);

  @$pb.TagNumber(3)
  $core.double get startX => $_getN(2);
  @$pb.TagNumber(3)
  set startX($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStartX() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartX() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get startY => $_getN(3);
  @$pb.TagNumber(4)
  set startY($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStartY() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartY() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get endX => $_getN(4);
  @$pb.TagNumber(5)
  set endX($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEndX() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndX() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get endY => $_getN(5);
  @$pb.TagNumber(6)
  set endY($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEndY() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndY() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get centerX => $_getN(6);
  @$pb.TagNumber(7)
  set centerX($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCenterX() => $_has(6);
  @$pb.TagNumber(7)
  void clearCenterX() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get centerY => $_getN(7);
  @$pb.TagNumber(8)
  set centerY($core.double v) { $_setFloat(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCenterY() => $_has(7);
  @$pb.TagNumber(8)
  void clearCenterY() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get radius => $_getN(8);
  @$pb.TagNumber(9)
  set radius($core.double v) { $_setFloat(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRadius() => $_has(8);
  @$pb.TagNumber(9)
  void clearRadius() => clearField(9);

  @$pb.TagNumber(10)
  Gradient_TileMode get tileMode => $_getN(9);
  @$pb.TagNumber(10)
  set tileMode(Gradient_TileMode v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasTileMode() => $_has(9);
  @$pb.TagNumber(10)
  void clearTileMode() => clearField(10);
}
