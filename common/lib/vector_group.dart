import 'package:collection/collection.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/vector_node.dart';
import 'package:svg2iv_common/vector_path.dart';

import 'transformations.dart';

class VectorGroup extends VectorNode {
  static const defaultScaleX = 1.0;
  static const defaultScaleY = 1.0;
  static const defaultPivotX = 0.0;
  static const defaultPivotY = 0.0;
  static const defaultTranslationX = 0.0;
  static const defaultTranslationY = 0.0;

  VectorGroup._init(
    this.nodes, {
    String? id,
    this.rotation,
    this.scale,
    this.translation,
    this.clipPathData,
  }) : super(id);

  final List<VectorNode> nodes;
  final Rotation? rotation;
  final Scale? scale;
  final Translation? translation;
  final List<PathNode>? clipPathData;

  bool get hasAttributes =>
      !id.isNullOrEmpty ||
      rotation != null ||
      scale != null ||
      translation != null ||
      !clipPathData.isNullOrEmpty;

  VectorGroup copyWith({
    List<VectorNode>? nodes,
    Rotation? rotation,
    Scale? scale,
    Translation? translation,
    List<PathNode>? clipPathData,
  }) {
    return VectorGroup._init(
      nodes ?? this.nodes,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      translation: translation ?? this.translation,
      clipPathData: clipPathData ?? this.clipPathData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorGroup &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(nodes, other.nodes) &&
          rotation == other.rotation &&
          scale == other.scale &&
          translation == other.translation &&
          const ListEquality().equals(clipPathData, other.clipPathData);

  @override
  int get hashCode =>
      const ListEquality().hash(nodes) ^
      rotation.hashCode ^
      scale.hashCode ^
      translation.hashCode ^
      const ListEquality().hash(clipPathData);
}

class VectorGroupBuilder
    extends VectorNodeBuilder<VectorGroup, VectorGroupBuilder> {
  VectorGroupBuilder();

  final _nodes = <VectorNode>[];
  Rotation? _rotation;
  Scale? _scale;
  Translation? _translation;
  List<PathNode>? _clipPathData;

  VectorGroupBuilder addNode(VectorNode node) {
    if (node is VectorGroup) {
      final group = node;
      node = group.copyWith(nodes: _mergePresentationAttributes(group.nodes));
    }
    _nodes.add(node);
    return this;
  }

  VectorGroupBuilder transformations(Transformations transformations) {
    _rotation = transformations.rotation;
    _scale = transformations.scale;
    _translation = transformations.translation;
    return this;
  }

  VectorGroupBuilder clipPathData(List<PathNode> clipPathData) {
    _clipPathData = clipPathData;
    return this;
  }

  List<VectorNode> _mergePresentationAttributes(List<VectorNode> nodes) {
    // "merge" presentation attributes, even when non-applicable
    return nodes.map(
      (node) {
        if (node is VectorPath) {
          final newFill = node.fill ?? fill_;
          var newStroke = node.stroke ?? stroke_;
          return node.copyWith(
            fill: newFill,
            fillAlpha: multiplyAlphas(
              multiplyAlphas(node.fillAlpha, fillAlpha_),
              alpha_?.takeIf((_) => newFill != null),
            ),
            stroke: newStroke,
            strokeAlpha: multiplyAlphas(
              multiplyAlphas(node.strokeAlpha, strokeAlpha_),
              alpha_?.takeIf((_) => newStroke != null),
            ),
            strokeLineWidth: node.strokeLineWidth ?? strokeLineWidth_,
            strokeLineCap: node.strokeLineCap ?? strokeLineCap_,
            strokeLineJoin: node.strokeLineJoin ?? strokeLineJoin_,
            strokeLineMiter: node.strokeLineMiter ?? strokeLineMiter_,
            pathFillType: node.pathFillType ?? pathFillType_,
          );
        } else {
          return (node as VectorGroup).copyWith(
            nodes: _mergePresentationAttributes(node.nodes),
          );
        }
      },
    ).toList();
  }

  @override
  VectorGroup build() {
    if (hasAttributes_) {
      final newNodes = _mergePresentationAttributes(_nodes);
      _nodes
        ..clear()
        ..addAll(newNodes);
    } else if (_rotation == null && _scale == null && _translation == null) {
      final onlyChild = _nodes.singleOrNull;
      if (onlyChild is VectorGroup) {
        // the current group is useless, merge it with its only child
        _nodes
          ..removeAt(0)
          ..addAll(onlyChild.nodes);
        onlyChild.id?.let((id) => this.id(id));
        _rotation = onlyChild.rotation;
        _scale = onlyChild.scale;
        _translation = onlyChild.translation;
      }
    }
    return VectorGroup._init(
      _nodes.toList(growable: false),
      id: id_,
      rotation: _rotation,
      scale: _scale,
      translation: _translation,
      clipPathData: _clipPathData,
    );
  }
}
