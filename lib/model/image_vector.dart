import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/model/vector_node.dart';

class ImageVector {
  ImageVector._init(
    this.nodes,
    this.viewportWidth,
    this.viewportHeight,
    this.width,
    this.height, [
    String? name,
  ]) : name = name?.toPascalCase();

  final List<VectorNode> nodes;
  final String? name;
  final double width, height;
  final double viewportWidth, viewportHeight;

  ImageVector copyWith({
    List<VectorNode>? nodes,
    String? name,
    double? width,
    height,
    double? viewportWidth,
    viewportHeight,
  }) {
    return ImageVector._init(
      nodes ?? this.nodes,
      viewportWidth ?? this.viewportWidth,
      viewportHeight ?? this.viewportHeight,
      width ?? this.width,
      height ?? this.height,
      name?.toPascalCase() ?? this.name,
    );
  }
}

class ImageVectorBuilder {
  ImageVectorBuilder(
    this._viewportWidth,
    this._viewportHeight,
  );

  final _nodes = <VectorNode>[];

  final double _viewportWidth, _viewportHeight;
  String? _name;
  double? _width, _height;

  ImageVectorBuilder name(String name) {
    _name = name;
    return this;
  }

  ImageVectorBuilder width(double width) {
    _width = width;
    return this;
  }

  ImageVectorBuilder height(double height) {
    _height = height;
    return this;
  }

  ImageVectorBuilder addNode(VectorNode node) {
    _nodes.add(node);
    return this;
  }

  ImageVectorBuilder addNodes(Iterable<VectorNode> nodes) {
    _nodes.addAll(nodes);
    return this;
  }

  ImageVector build() {
    return ImageVector._init(
      _nodes,
      _viewportWidth,
      _viewportHeight,
      _width ?? _viewportWidth,
      _height ?? _viewportHeight,
      _name,
    );
  }
}
