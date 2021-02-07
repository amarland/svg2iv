import 'package:collection/collection.dart';
import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/transformations.dart';
import 'package:svg2va/model/vector_node.dart';
import 'package:svg2va/model/vector_path.dart';

class VectorGroup extends VectorNode {
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
    double? multiplyAlphas(double? alpha1, double? alpha2) =>
        alpha1 == null ? alpha2 : (alpha2 == null ? alpha1 : alpha1 * alpha2);

    // "merge" presentation attributes, even when non-applicable
    return nodes
        .map((node) => node is VectorPath
            ? node.copyWith(
                fill: node.fill ?? fill_,
                fillAlpha: multiplyAlphas(node.fillAlpha, fillAlpha_),
                stroke: node.stroke ?? stroke_,
                strokeAlpha: multiplyAlphas(node.strokeAlpha, strokeAlpha_),
                strokeLineWidth: node.strokeLineWidth ?? strokeLineWidth_,
                strokeLineCap: node.strokeLineCap ?? strokeLineCap_,
                strokeLineJoin: node.strokeLineJoin ?? strokeLineJoin_,
                strokeLineMiter: node.strokeLineMiter ?? strokeLineMiter_,
                pathFillType: node.pathFillType ?? pathFillType_,
              )
            : node)
        .toList();
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
