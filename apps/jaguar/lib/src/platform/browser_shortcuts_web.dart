import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Keys that, with Ctrl or Cmd, are Jaguar shortcuts: save, open, go to
/// line, side panel, comment, font size, run, find, replace and delete line.
const _withPrimary = {'s', 'o', 'g', 'b', '/', '=', '+', '-', '0', 'enter', 'f', 'h', 'k'};

/// Run and stop, as in PSeInt and DFD (F9) and other editors (F5), step by
/// step (F7 as in DFD, F10) and run to here (F4, as in DFD).
const _alone = {'f1', 'f4', 'f5', 'f7', 'f9', 'f10'};

/// Flutter handles the app's shortcuts, but the browser would act on them
/// too: Ctrl+S would save the web page and F5 would reload it.
void keepBrowserShortcutsForApp() {
  web.window.addEventListener(
    'keydown',
    ((web.KeyboardEvent event) {
      final key = event.key.toLowerCase();
      final primary = event.ctrlKey || event.metaKey;
      if ((primary && _withPrimary.contains(key)) || _alone.contains(key)) event.preventDefault();
    }).toJS,
    true.toJS,
  );
}
