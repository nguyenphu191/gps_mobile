import 'dart:io';

void main() {
  var d = Directory('lib');
  for (var f in d.listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      var text = f.readAsStringSync();
      var newText = text.replaceAll('EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);', '// EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);');
      if (text != newText) {
        f.writeAsStringSync(newText);
      }
    }
  }
}
