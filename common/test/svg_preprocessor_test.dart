import 'package:svg2iv_common/svg_preprocessor.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('<defs> elements are moved if needed;', () {
    void actualTest(String description, String svgAsString) {
      test(description, () {
        final svgElement = XmlDocument.parse(svgAsString).rootElement;
        preprocessSvg(svgElement);
        expect(svgElement.firstElementChild!.name.local, 'defs');
      });
    }

    actualTest(
      'when it is already where expected',
      '<svg><defs /><rect width="10" height="10" /></svg>',
    );
    actualTest(
      'when it is not where expected',
      '<svg><rect width="10" height="10" /><defs /></svg>',
    );
  });

  test(
    '<use> elements are inlined and their attributes properly "propagated"',
    () {
      const sourceDocument = '''
<svg viewBox="0 0 40 10" xmlns="http://www.w3.org/2000/svg">
  <circle id="circle" cx="5" cy="5" r="4" stroke="blue" />
  <use href="#circle" x="10" fill="blue" />
  <use href="#circle" x="20" fill="white" stroke="red" id="ref_circle" />
  <use href="#ref_circle" x="30" stroke-opacity="0.7" />
</svg>''';
      const expectedDocument = '''
  <!--suppress HtmlUnknownAttribute-->
  <svg viewBox="0 0 40 10" xmlns="http://www.w3.org/2000/svg">
  <circle cx="5" cy="5" r="4"              stroke="blue" id="circle" />
  <circle cx="5" cy="5" r="4" fill="blue"  stroke="blue" use_x="10.0" />
  <circle cx="5" cy="5" r="4" fill="white" stroke="blue" use_x="20.0"
          id="ref_circle" />
  <circle cx="5" cy="5" r="4" fill="white" stroke="blue" use_x="30.0"
          stroke-opacity="0.7" />
</svg>''';
      final expectedSvgElement =
          XmlDocument.parse(expectedDocument).rootElement;
      final actualSvgElement = XmlDocument.parse(sourceDocument).rootElement;
      preprocessSvg(actualSvgElement);
      expect(_prettify(actualSvgElement), _prettify(expectedSvgElement));
    },
  );

  test(
    '<clipPath> elements are all inside <defs> and cross-references are nested',
    () {
      const sourceDocument = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="clip_path2">
      <path d="M 6 6 L 20 4 L 20 20 L 6 20 L 6 6 Z"
            clip-path="url(#clip_path2_1)" />
    </clipPath>
    <clipPath id="clip_path2_1">
      <path d="M 8 8 L 16 8 L 16 16 L 8 16 L 8 8 Z"
            clip-path="url(#clip_path2_2)" />
    </clipPath>
    <clipPath id="clip_path2_2">
      <path d="M 10 10 L 12 10 L 12 12 L 10 12 L 10 10 Z" />
    </clipPath>
  </defs>
  <clipPath id="clip_path1">
    <path d="M 4 4 L 24 4 L 24 24 L 4 24 L 4 4 Z" />
  </clipPath>
  <path id="path1" clip-path="url(#clip_path1)"
        d="M 0 0 L 24 0 L 24 24 L 0 24 L 0 0 Z" fill="#FFF000" />
  <path id="path2" clip-path="url(#clip_path2)"
        d="M 0 0 L 24 0 L 24 24 L 0 24 L 0 0 Z" fill="#000FFF" />
</svg>''';
      const expectedDocument = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="clip_path1">
      <path d="M 4 4 L 24 4 L 24 24 L 4 24 L 4 4 Z" />
    </clipPath>
    <clipPath id="clip_path2">
      <path d="M 10 10 L 12 10 L 12 12 L 10 12 L 10 10 Z" />
      <clipPath>
        <path d="M 8 8 L 16 8 L 16 16 L 8 16 L 8 8 Z" />
        <clipPath>
          <path d="M 6 6 L 20 4 L 20 20 L 6 20 L 6 6 Z" />
        </clipPath>
      </clipPath>
    </clipPath>
    <clipPath id="clip_path2_1">
      <path d="M 10 10 L 12 10 L 12 12 L 10 12 L 10 10 Z" />
      <clipPath>
        <path d="M 8 8 L 16 8 L 16 16 L 8 16 L 8 8 Z" />
      </clipPath>
    </clipPath>
    <clipPath id="clip_path2_2">
      <path d="M 10 10 L 12 10 L 12 12 L 10 12 L 10 10 Z" />
    </clipPath>
  </defs>
  <path id="path1" clip-path="url(#clip_path1)"
        d="M 0 0 L 24 0 L 24 24 L 0 24 L 0 0 Z" fill="#FFF000" />
  <path id="path2" clip-path="url(#clip_path2)"
        d="M 0 0 L 24 0 L 24 24 L 0 24 L 0 0 Z" fill="#000FFF" />
</svg>''';
      final expectedSvgElement =
          XmlDocument.parse(expectedDocument).rootElement;
      final actualSvgElement = XmlDocument.parse(sourceDocument).rootElement;
      preprocessSvg(actualSvgElement);
      _sortDefinitions(actualSvgElement);
      _sortDefinitions(expectedSvgElement);
      expect(
        actualSvgElement.toXmlString(pretty: true),
        expectedSvgElement.toXmlString(pretty: true),
      );
    },
  );

  test(
    'CSS style attributes are converted to SVG presentation attributes',
    () {
      const sourceDocument = '''
<svg viewBox="0 0 100 60" xmlns="http://www.w3.org/2000/svg">
  <rect width="80" height="40" x="10" y="10"
        style="fill: blue; stroke: yellow; stroke-width: 2;" />
</svg>''';
      const expectedDocument = '''
<svg viewBox="0 0 100 60" xmlns="http://www.w3.org/2000/svg">
  <rect width="80" height="40" x="10" y="10"
        fill="blue" stroke="yellow" stroke-width="2" />
</svg>''';
      final expectedSvgElement =
          XmlDocument.parse(expectedDocument).rootElement;
      final actualSvgElement = XmlDocument.parse(sourceDocument).rootElement;
      preprocessSvg(actualSvgElement);
      expect(_prettify(actualSvgElement), _prettify(expectedSvgElement));
    },
  );
}

int _sortAttributes(XmlAttribute attr1, XmlAttribute attr2) =>
    attr1.name.qualified.compareTo(attr2.name.qualified);

String _prettify(XmlElement element) => element.toXmlString(
      pretty: true,
      sortAttributes: _sortAttributes,
    );

void _sortDefinitions(XmlElement rootElement) {
  rootElement.firstElementChild!.children.sort(
    (e1, e2) => e1
        .getAttribute('id')
        .orEmpty()
        .compareTo(e2.getAttribute('id').orEmpty()),
  );
}
