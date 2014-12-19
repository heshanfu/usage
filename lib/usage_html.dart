// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * In order to use this library import the `usage_html.dart` file and
 * instantiate the [AnalyticsHtml] class.
 *
 * You'll need to provide a Google Analytics tracking ID, the application name,
 * and the application version.
 */
library usage_html;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';

import 'src/usage_impl.dart';

export 'usage.dart';

/**
 * An interface to a Google Analytics session, suitable for use in web apps.
 */
class AnalyticsHtml extends AnalyticsImpl {
  AnalyticsHtml(String trackingId, String applicationName, String applicationVersion) :
    super(
      trackingId,
      new _PersistentProperties(applicationName),
      new _PostHandler(),
      applicationName: applicationName,
      applicationVersion: applicationVersion);
}

class _PostHandler extends PostHandler {
  Future sendPost(String url, Map<String, String> parameters) {
    int screenWidth = window.screen.width;
    int screenHeight = window.screen.height;
    int clientWidth = document.documentElement.clientWidth;
    int clientHeight = document.documentElement.clientHeight;

    parameters['sr'] = '${screenWidth}x$screenHeight';
    parameters['vp'] = '${clientWidth}x$clientHeight';
    parameters['sd'] = '${window.screen.pixelDepth}-bits';
    parameters['ul'] = window.navigator.language;

    String data = postEncode(parameters);
    return HttpRequest.request(url, method: 'POST', sendData: data);
  }
}

class _PersistentProperties extends PersistentProperties {
  Map _map;

  _PersistentProperties(String name) : super(name) {
    String str = window.localStorage[name];
    if (str == null || str.isEmpty) str = '{}';
    _map = JSON.decode(str);
  }

  dynamic operator[](String key) => _map[key];

  void operator[]=(String key, dynamic value) {
    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }

    window.localStorage[name] = JSON.encode(_map);
  }
}
