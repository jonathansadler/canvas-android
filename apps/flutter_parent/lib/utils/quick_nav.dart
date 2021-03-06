// Copyright (C) 2019 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuickNav {
  Future<T> push<T extends Object>(BuildContext context, Widget widget) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  /// Clears the back stack of any routes currently in the navigation and adds the new widget
  Future<T> pushAndRemoveAll<T extends Object>(BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => widget), (_) => false);
  }

  /// Replace the current route of the navigator with the provided route
  Future<T> replaceRoute<T extends Object>(BuildContext context, Route<T> newRoute) {
    return Navigator.pushReplacement(context, newRoute);
  }
}
