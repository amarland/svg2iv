import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomMaterialLocalizations extends DefaultMaterialLocalizations {
  const CustomMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _CustomMaterialLocalizationsDelegate();

  @override
  String get closeButtonLabel => _transform(super.closeButtonLabel);

  @override
  String get viewLicensesButtonLabel =>
      _transform(super.viewLicensesButtonLabel);

  String _transform(String value) =>
      value[0] + value.substring(1).toLowerCase();
}

class _CustomMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CustomMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        const CustomMaterialLocalizations(),
      );

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) => false;
}
