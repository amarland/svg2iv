import 'package:collection/collection.dart';

import '../extensions.dart';
import 'path_node.dart';
import 'transformations.dart';
import 'vector_node.dart';

class VectorGroup extends VectorNode {
  static const defaultScaleX = 1.0;
  static const defaultScaleY = 1.0;
  static const defaultPivotX = 0.0;
  static const defaultPivotY = 0.0;
  static const defaultTranslationX = 0.0;
  static const defaultTranslationY = 0.0;

  const VectorGroup._(
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

  bool get definesTransformations =>
      rotation != null ||
      scale != null ||
      translation != null ||
      !clipPathData.isNullOrEmpty;

  VectorGroup copyWith({
    List<VectorNode>? nodes,
    String? id,
    Rotation? rotation,
    Scale? scale,
    Translation? translation,
    List<PathNode>? clipPathData,
  }) {
    return VectorGroup._(
      nodes ?? this.nodes,
      id: id ?? this.id,
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
          const ListEquality<VectorNode>().equals(nodes, other.nodes) &&
          rotation == other.rotation &&
          scale == other.scale &&
          translation == other.translation &&
          const ListEquality<PathNode>()
              .equals(clipPathData, other.clipPathData);

  @override
  int get hashCode =>
      const ListEquality<VectorNode>().hash(nodes) ^
      rotation.hashCode ^
      scale.hashCode ^
      translation.hashCode ^
      const ListEquality<PathNode>().hash(clipPathData);
}

class VectorGroupBuilder
    extends VectorNodeBuilder<VectorGroup, VectorGroupBuilder> {
  VectorGroupBuilder();

  List<VectorNode> _nodes = [];
  Rotation? _rotation;
  Scale? _scale;
  Translation? _translation;
  List<PathNode>? _clipPathData;

  VectorGroupBuilder addNode(VectorNode node) {
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

  @override
  VectorGroup build() {
    if (_rotation == null &&
        _scale == null &&
        _translation == null &&
        _clipPathData.isNullOrEmpty) {
      final onlyChild = _nodes.singleOrNull;
      if (onlyChild is VectorGroup) {
        // the current group is useless, merge it with its only child
        _nodes = onlyChild.nodes;
        onlyChild.id?.let((id) => this.id(id));
        _rotation = onlyChild.rotation;
        _scale = onlyChild.scale;
        _translation = onlyChild.translation;
        _clipPathData = onlyChild.clipPathData;
      }
    }
    final indicesOfGroupsToRemove = <int>[];
    _nodes.forEachIndexed((index, node) {
      if (node is VectorGroup) {
        if (!node.definesTransformations) {
          // the child is useless, merge it with its parent (the current group)
          indicesOfGroupsToRemove.add(index);
        }
      }
    });
    var insertedNodeCount = 0;
    for (final index in indicesOfGroupsToRemove) {
      final revisedIndex = index + insertedNodeCount;
      final group = _nodes[revisedIndex] as VectorGroup;
      _nodes
        ..removeAt(index)
        ..insertAll(index, group.nodes);
      insertedNodeCount += group.nodes.length - 1;
      group.id?.let((id) => this.id(id));
    }
    return VectorGroup._(
      _nodes.toNonGrowableList(),
      id: id_,
      rotation: _rotation,
      scale: _scale,
      translation: _translation,
      clipPathData: _clipPathData,
    );
  }
}
