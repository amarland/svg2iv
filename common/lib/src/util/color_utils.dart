// TODO: add a `Color` class?

int alphaForColorInt(int value) => (0xFF000000 & value) >> 24;

List<int> colorIntToArgb(int value) {
  return List.generate(
    4,
    (index) {
      final shift = index * 8;
      return (((0xFFFF0000 >> (shift)) & value) >> (24 - shift));
    },
    growable: false,
  );
}

List<double> colorIntToRgbFractions(int value) {
  return List.generate(
    3,
    (index) {
      final shift = index * 8;
      return (((0x00FF0000 >> (shift)) & value) >> (16 - shift)) / 255.0;
    },
    growable: false,
  );
}
