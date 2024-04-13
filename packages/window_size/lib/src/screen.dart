// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:ui';

/// Represents a screen, containing information about its size, position, and
/// properties.
class Screen {
  /// Create a new screen.
  Screen(this.frame, this.visibleFrame, this.scaleFactor);

  /// The frame of the screen, in screen coordinates.
  final Rect frame;

  /// The portion of the screen's frame that is available for use by application
  /// windows. E.g., on macOS, this excludes the menu bar.
  final Rect visibleFrame;

  /// The number of pixels per screen coordinate for this screen.
  final double scaleFactor;
}
