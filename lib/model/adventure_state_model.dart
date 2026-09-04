import 'package:flutter/material.dart';

/// Chapters and Reveal stages of the Adventure Experience
enum AdventureChapter {
  intro,
  chapter1,           // Part 1: First Impressions (3 Instinct Choices)
  chapter1Complete,   // Transition Bridge 1
  chapter2Intro,      // Transition into Part 2
  chapter2,           // Part 2: The Trail (3 Reactive Situations)
  chapter2Complete,   // Transition Bridge 2
  chapter3Intro,      // Transition into Part 3 (Prologue)
  chapter3,           // Part 3: Shared Moments (3 Moments - Path B begins)
  chapter3Complete,   // Transition Bridge 3
  chapter3Placeholder,// Backward compatibility alias
  revealConvergence,  // Animating dual-path convergence & final landmark
  revealText,         // "Turns out, I wasn't really trying to find a place..."
  revealYou,          // "YOU."
  invitationReady,    // "Want to find somewhere with me?" + YES / TELL ME MORE
  reveal,             // Legacy alias
  invitation,         // Legacy alias
}

/// Detailed sequential stages of the cinematic reveal storyboard
enum RevealStage {
  none,           // Normal gameplay before reveal
  expanding,      // 1. Map expands to full screen (0.0 - 1.2s)
  pathsMerging,   // 2. Paths meet at compass (1.2 - 2.8s)
  compassRising,  // 3. Compass rises up, paths merge into one (2.8 - 3.6s)
  firstThought,   // 4. First sentence appears and stays (3.6 - 4.8s)
  secondThought,  // 5. Second sentence appears below (4.8 - 6.0s)
  youClimax,      // 5. "YOU." appears in center (6.0 - 7.5s)
  holdMoment,     // 5. 2-second emotional hold (7.5 - 9.5s)
  invitationCard, // 6. Invitation card rises up (9.5s onward)
}

/// Relative position for a landmark's text label
enum LabelPosition {
  below,
  above,
  left,
  right,
}

/// Single Source of Truth for an adventure choice, its visual manifestation,
/// map coordinates, asset, and downstream consequences.
class AdventureChoiceDefinition {
  final String id;
  final String optionText;
  final String storedValue;
  final String assetPath;
  final String mapLabel;
  final String landmarkId;
  final Offset normalizedPosition;
  final bool isPathB;
  final LabelPosition labelPosition;
  final bool showLabel;
  final bool isPrimary;
  final IconData? icon;
  final String? narrativeConsequence;

  const AdventureChoiceDefinition({
    required this.id,
    required this.optionText,
    required this.storedValue,
    required this.assetPath,
    required this.mapLabel,
    required this.landmarkId,
    required this.normalizedPosition,
    this.isPathB = false,
    this.labelPosition = LabelPosition.below,
    this.showLabel = true,
    this.isPrimary = true,
    this.icon,
    this.narrativeConsequence,
  });

  /// Convert into a MapLandmarkNode for direct map rendering
  MapLandmarkNode toMapNode({required int stepRevealed, double size = 32.0}) {
    return MapLandmarkNode(
      id: landmarkId,
      assetPath: assetPath,
      label: mapLabel,
      normalizedPosition: normalizedPosition,
      size: size,
      stepRevealed: stepRevealed,
      isSecondary: isPathB,
      showLabel: showLabel,
      isPrimary: isPrimary,
      labelPosition: labelPosition,
    );
  }
}

/// Legacy alias for backward compatibility
typedef AdventureChoiceConsequence = AdventureChoiceDefinition;
typedef Chapter3ChoiceConsequence = AdventureChoiceDefinition;

/// Represents an instinct decision in Part 1 (First Impressions)
class Chapter1Question {
  final int index;
  final String id;
  final String prompt;
  final String? subtitle;
  final AdventureChoiceDefinition definitionA;
  final AdventureChoiceDefinition definitionB;

  const Chapter1Question({
    required this.index,
    required this.id,
    required this.prompt,
    this.subtitle,
    required this.definitionA,
    required this.definitionB,
  });

  String get optionA => definitionA.optionText;
  String get optionB => definitionB.optionText;
  IconData? get iconA => definitionA.icon;
  IconData? get iconB => definitionB.icon;
}

/// Represents an interactive situation in Part 2 (The Trail)
class Chapter2Situation {
  final int index;
  final String id;
  final String title;
  final String promptLine1;
  final String? promptLine2;
  final String? promptLine3;
  final AdventureChoiceDefinition definitionA;
  final AdventureChoiceDefinition definitionB;

  const Chapter2Situation({
    required this.index,
    required this.id,
    required this.title,
    required this.promptLine1,
    this.promptLine2,
    this.promptLine3,
    required this.definitionA,
    required this.definitionB,
  });

  String get optionA => definitionA.optionText;
  String get optionB => definitionB.optionText;
  IconData? get iconA => definitionA.icon;
  IconData? get iconB => definitionB.icon;
  AdventureChoiceDefinition? get consequenceA => definitionA;
  AdventureChoiceDefinition? get consequenceB => definitionB;
}

/// Represents a shared moment in Part 3 (Shared Moments)
class Chapter3Interaction {
  final int index;
  final String id;
  final String title;
  final String promptLine1;
  final String? promptLine2;
  final String? promptLine3;
  final AdventureChoiceDefinition definitionA;
  final AdventureChoiceDefinition definitionB;

  const Chapter3Interaction({
    required this.index,
    required this.id,
    required this.title,
    required this.promptLine1,
    this.promptLine2,
    this.promptLine3,
    required this.definitionA,
    required this.definitionB,
  });

  String get optionA => definitionA.optionText;
  String get optionB => definitionB.optionText;
  IconData? get iconA => definitionA.icon;
  IconData? get iconB => definitionB.icon;
  AdventureChoiceDefinition? get consequenceA => definitionA;
  AdventureChoiceDefinition? get consequenceB => definitionB;
}

/// Represents a visual landmark / node on the dynamic illustrated adventure map
class MapLandmarkNode {
  final String id;
  final String assetPath;
  final String label;
  final Offset normalizedPosition; // x: 0.0-1.0, y: 0.0-1.0
  final double size;
  final int stepRevealed;
  final bool isSecondary;
  final bool showLabel;
  final bool isPrimary;
  final LabelPosition labelPosition;

  const MapLandmarkNode({
    required this.id,
    required this.assetPath,
    required this.label,
    required this.normalizedPosition,
    this.size = 32.0,
    required this.stepRevealed,
    this.isSecondary = false,
    this.showLabel = true,
    this.isPrimary = true,
    this.labelPosition = LabelPosition.below,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetPath': assetPath,
    'label': label,
    'x': normalizedPosition.dx,
    'y': normalizedPosition.dy,
    'size': size,
    'stepRevealed': stepRevealed,
    'isSecondary': isSecondary,
    'showLabel': showLabel,
    'isPrimary': isPrimary,
    'labelPosition': labelPosition.name,
  };

  factory MapLandmarkNode.fromJson(Map<String, dynamic> json) =>
      MapLandmarkNode(
        id: json['id'] as String? ?? '',
        assetPath: json['assetPath'] as String? ?? '',
        label: json['label'] as String? ?? '',
        normalizedPosition: Offset(
          (json['x'] as num?)?.toDouble() ?? 0.0,
          (json['y'] as num?)?.toDouble() ?? 0.0,
        ),
        size: (json['size'] as num?)?.toDouble() ?? 32.0,
        stepRevealed: (json['stepRevealed'] as num?)?.toInt() ?? 0,
        isSecondary: json['isSecondary'] as bool? ?? false,
        showLabel: json['showLabel'] as bool? ?? true,
        isPrimary: json['isPrimary'] as bool? ?? true,
        labelPosition: LabelPosition.values.firstWhere(
          (e) => e.name == json['labelPosition'],
          orElse: () => LabelPosition.below,
        ),
      );
}

/// Represents a programmatic bezier path segment on the map
class MapRouteSegment {
  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;
  final bool isWinding;
  final int step;
  final bool isBranch;
  final bool isSecondaryPath;

  const MapRouteSegment({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    this.isWinding = false,
    required this.step,
    this.isBranch = false,
    this.isSecondaryPath = false,
  });

  Map<String, dynamic> toJson() => {
    'startX': start.dx,
    'startY': start.dy,
    'c1X': control1.dx,
    'c1Y': control1.dy,
    'c2X': control2.dx,
    'c2Y': control2.dy,
    'endX': end.dx,
    'endY': end.dy,
    'isWinding': isWinding,
    'step': step,
    'isBranch': isBranch,
    'isSecondaryPath': isSecondaryPath,
  };

  factory MapRouteSegment.fromJson(Map<String, dynamic> json) =>
      MapRouteSegment(
        start: Offset(
          (json['startX'] as num?)?.toDouble() ?? 0.0,
          (json['startY'] as num?)?.toDouble() ?? 0.0,
        ),
        control1: Offset(
          (json['c1X'] as num?)?.toDouble() ?? 0.0,
          (json['c1Y'] as num?)?.toDouble() ?? 0.0,
        ),
        control2: Offset(
          (json['c2X'] as num?)?.toDouble() ?? 0.0,
          (json['c2Y'] as num?)?.toDouble() ?? 0.0,
        ),
        end: Offset(
          (json['endX'] as num?)?.toDouble() ?? 0.0,
          (json['endY'] as num?)?.toDouble() ?? 0.0,
        ),
        isWinding: json['isWinding'] as bool? ?? false,
        step: (json['step'] as num?)?.toInt() ?? 0,
        isBranch: json['isBranch'] as bool? ?? false,
        isSecondaryPath: json['isSecondaryPath'] as bool? ?? false,
      );
}
