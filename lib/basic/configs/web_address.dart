import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nhentai/basic/channels/nhentai.dart';
import 'package:nhentai/basic/common/common.dart';

late List<String> _availableWebAddresses;
late String _webAddress;

Future<void> initWebAddressConfig() async {
  _availableWebAddresses = await nHentai.availableWebAddresses();
  _webAddress = await nHentai.getWebAddress();
}

Widget webAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      var none = AppLocalizations.of(context)!.none;
      Map<String, String> map = {};
      map[none] = "";
      for (var element in _availableWebAddresses) {
        map[element] = element;
      }
      return ListTile(
        title: Text(AppLocalizations.of(context)!.webAddress),
        subtitle: Text(_webAddress == "" ? none : _webAddress),
        onTap: () async {
          var result = await chooseMapDialog<String>(
            context,
            map,
            AppLocalizations.of(context)!.chooseWebAddress,
          );
          if (result != null) {
            nHentai.setWebAddress(result);
            _webAddress = result;
          }
          setState(() {});
        },
      );
    },
  );
}
