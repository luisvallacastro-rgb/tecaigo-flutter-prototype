// ignore_for_file: deprecated_member_use

import 'dart:html' as html;

String? storageRead(String key) => html.window.localStorage[key];

void storageWrite(String key, String value) {
  html.window.localStorage[key] = value;
}
