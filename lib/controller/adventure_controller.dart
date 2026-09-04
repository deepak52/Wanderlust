import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/adventure_assets.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/core/theme/color_helper.dart';
import '../helper/route.dart';
import '../model/adventure_state_model.dart';
import '../service/chat_service.dart';

class AdventureController extends AppBaseController
    with GetTickerProviderStateMixin {
  // ==================== REACTIVE STATE ====================
  final Rx<AdventureChapter> rxChapter = AdventureChapter.intro.obs;
  final RxInt rxCurrentQuestionIndex = 0.obs;
  final RxInt rxCurrentSituationIndex = 0.obs;
  final RxInt rxCurrentInteractionIndex = 0.obs;
  final RxMap<String, String> rxSelectedChoices = <String, String>{}.obs;
  final RxString rxSelectedCurrentOption = ''.obs;
  final RxBool rxIsAdvancing = false.obs;
  final RxString rxSelectedInvitationResponse = ''.obs;
  final RxInt rxRevealTextStep = 0.obs;
  final Rx<RevealStage> rxRevealStage = RevealStage.none.obs;
  final RxDouble rxPathMergeProgress = 0.0.obs;
  final RxDouble rxTrailOpacity = 1.0.obs;
  final RxDouble rxCompassNormalizedY = 0.82.obs;
  final RxDouble rxUnifiedPathProgress = 0.0.obs;
  final RxBool rxShowUnifiedPath = false.obs;

  bool get isRevealing => rxRevealStage.value != RevealStage.none;

  // Map state
  final RxList<MapLandmarkNode> rxMapNodes = <MapLandmarkNode>[].obs;
  final RxList<MapRouteSegment> rxPathSegments = <MapRouteSegment>[].obs;
  final RxDouble rxPathAnimationProgress = 0.0.obs;

  // Animation Controllers
  late AnimationController mapAnimController;
  late Animation<double> mapProgressAnimation;

  // ==================== PART 1: FIRST IMPRESSIONS (3 Instinct Decisions) ====================
  static const List<Chapter1Question> chapter1Questions = [
    // D1: Atmosphere (Lower-left, plenty of breathing room from edge)
    Chapter1Question(
      index: 1,
      id: 'q1',
      prompt: 'You arrive at a new place.',
      subtitle: 'What would you love to see first?',
      definitionA: AdventureChoiceDefinition(
        id: 'd1_sunrise',
        optionText: 'SUNRISE',
        storedValue: 'SUNRISE',
        assetPath: AdventureAssets.expSunrise,
        mapLabel: 'SUNRISE',
        landmarkId: 'node_d1_sunrise',
        normalizedPosition: Offset(0.24, 0.72),
        labelPosition: LabelPosition.right,
        icon: Icons.wb_sunny_outlined,
        narrativeConsequence: 'Sets morning atmosphere across the journey.',
      ),
      definitionB: AdventureChoiceDefinition(
        id: 'd1_sunset',
        optionText: 'SUNSET',
        storedValue: 'SUNSET',
        assetPath: AdventureAssets.expSunset,
        mapLabel: 'SUNSET',
        landmarkId: 'node_d1_sunset',
        normalizedPosition: Offset(0.24, 0.72),
        labelPosition: LabelPosition.right,
        icon: Icons.nights_stay_outlined,
        narrativeConsequence: 'Sets evening atmosphere across the journey.',
      ),
    ),

    // D2: Travel Style (Ascending mid-west trail)
    Chapter1Question(
      index: 2,
      id: 'q2',
      prompt: 'The road ahead is not what you expected.',
      subtitle: 'What do you do?',
      definitionA: AdventureChoiceDefinition(
        id: 'd2_plan',
        optionText: 'PLAN THE WAY',
        storedValue: 'PLAN THE WAY',
        assetPath: AdventureAssets.mapTreePine,
        mapLabel: 'PINE TRAIL',
        landmarkId: 'node_d2_pine_trail',
        normalizedPosition: Offset(0.22, 0.54),
        labelPosition: LabelPosition.right,
        icon: Icons.map_outlined,
        narrativeConsequence: 'Sets structured route preferences.',
      ),
      definitionB: AdventureChoiceDefinition(
        id: 'd2_explore',
        optionText: 'SEE WHERE IT GOES',
        storedValue: 'SEE WHERE IT GOES',
        assetPath: AdventureAssets.mapSignpost,
        mapLabel: 'TRAIL',
        landmarkId: 'node_d2_signpost',
        normalizedPosition: Offset(0.22, 0.54),
        labelPosition: LabelPosition.right,
        icon: Icons.explore_outlined,
        narrativeConsequence: 'Sets spontaneous exploration preferences.',
      ),
    ),

    // D3: Memory Focus (Upper-west vantage point)
    Chapter1Question(
      index: 3,
      id: 'q3',
      prompt: 'You see something beautiful.',
      subtitle: 'How do you want to remember it?',
      definitionA: AdventureChoiceDefinition(
        id: 'd3_photos',
        optionText: 'TAKE LOTS OF PHOTOS',
        storedValue: 'TAKE LOTS OF PHOTOS',
        assetPath: AdventureAssets.expCamera,
        mapLabel: 'MEMORIES',
        landmarkId: 'node_d3_camera',
        normalizedPosition: Offset(0.28, 0.38),
        labelPosition: LabelPosition.left,
        icon: Icons.photo_camera_outlined,
        narrativeConsequence: 'Sets documentary memory focus.',
      ),
      definitionB: AdventureChoiceDefinition(
        id: 'd3_moment',
        optionText: 'KEEP THE MOMENT',
        storedValue: 'KEEP THE MOMENT',
        assetPath: AdventureAssets.expBackpack,
        mapLabel: 'VANTAGE',
        landmarkId: 'node_d3_backpack',
        normalizedPosition: Offset(0.28, 0.38),
        labelPosition: LabelPosition.left,
        icon: Icons.camera_alt_outlined,
        narrativeConsequence: 'Sets experiential memory focus.',
      ),
    ),
  ];

  // ==================== PART 2: THE TRAIL (3 Reactive Situations) ====================
  List<Chapter2Situation> get chapter2Situations =>
      _buildPersonalizedTrailSituations();

  List<Chapter2Situation> _buildPersonalizedTrailSituations() {
    final q1 = rxSelectedChoices['q1'] ?? 'SUNRISE';
    final q2 = rxSelectedChoices['q2'] ?? 'PLAN THE WAY';

    final isSunrise = q1 == 'SUNRISE';
    final isPlanIt = q2 == 'PLAN THE WAY';

    return [
      // S1: Horizon Split (Climbing ridge approach)
      Chapter2Situation(
        index: 1,
        id: 'chapter2_q1',
        title: isSunrise ? 'THE FIRST LIGHT' : 'THE GOLDEN HOUR',
        promptLine1: isSunrise
            ? 'You have two hours before sunrise.'
            : 'You have two hours before sunset.',
        promptLine2: 'The trail splits into two paths ahead.',
        promptLine3: isSunrise
            ? 'One goes straight up to the peak. The other winds through the easy valley.'
            : 'One climbs fast toward the sunset view. The other takes the slow, winding path.',
        definitionA: AdventureChoiceDefinition(
          id: 's1_vantage',
          optionText: isSunrise ? 'MAKE IT IN TIME' : 'HURRY FOR THE VIEW',
          storedValue: isSunrise ? 'MAKE IT IN TIME' : 'HURRY FOR THE VIEW',
          assetPath: AdventureAssets.mapHill,
          mapLabel: 'VANTAGE',
          landmarkId: 'node_s1_vantage',
          normalizedPosition: const Offset(0.32, 0.28),
          labelPosition: LabelPosition.left,
          icon: Icons.terrain_rounded,
        ),
        definitionB: const AdventureChoiceDefinition(
          id: 's1_detour',
          optionText: 'TAKE THE LONG WAY',
          storedValue: 'TAKE THE LONG WAY',
          assetPath: AdventureAssets.mapBridge,
          mapLabel: 'DETOUR',
          landmarkId: 'node_s1_detour',
          normalizedPosition: Offset(0.32, 0.28),
          labelPosition: LabelPosition.left,
          icon: Icons.alt_route_rounded,
        ),
      ),

      // S2: The Ridge (Well below the top header with generous breathing room)
      Chapter2Situation(
        index: 2,
        id: 'chapter2_q2',
        title: isPlanIt ? 'THE PLANNED PATH' : 'THE UNMARKED PATH',
        promptLine1: isPlanIt
            ? 'The climb is steep, but this was the route you planned.'
            : 'You find a path that was not on the map.',
        promptLine2: isPlanIt
            ? "It's harder, but promises a view from the top."
            : 'A rocky trail goes straight up, or a green path leads through the trees.',
        promptLine3: isPlanIt
            ? 'Or you could take the quiet path through the pine trees.'
            : 'Which way do you want to explore?',
        definitionA: AdventureChoiceDefinition(
          id: 's2_ridge',
          optionText: isPlanIt ? 'TAKE THE RIDGE' : 'CLIMB UP',
          storedValue: isPlanIt ? 'TAKE THE RIDGE' : 'CLIMB UP',
          assetPath: AdventureAssets.mapMountain,
          mapLabel: 'RIDGE CREST',
          landmarkId: 'node_s2_ridge',
          normalizedPosition: const Offset(0.42, 0.20),
          labelPosition: LabelPosition.below,
          icon: Icons.landscape_outlined,
        ),
        definitionB: AdventureChoiceDefinition(
          id: 's2_pines',
          optionText: isPlanIt ? 'TAKE THE PINE PATH' : 'FOLLOW THE TREES',
          storedValue: isPlanIt ? 'TAKE THE PINE PATH' : 'FOLLOW THE TREES',
          assetPath: AdventureAssets.mapTreePine,
          mapLabel: 'PINES',
          landmarkId: 'node_s2_pines',
          normalizedPosition: const Offset(0.42, 0.20),
          labelPosition: LabelPosition.below,
          icon: Icons.forest_outlined,
        ),
      ),

      // S3: The Crossing (North-central river crossing)
      const Chapter2Situation(
        index: 3,
        id: 'chapter2_q3',
        title: 'THE CROSSING',
        promptLine1: 'Rain starts falling on the trail.',
        promptLine2:
            'There is an old stone bridge ahead and a dry shelter behind you.',
        promptLine3: 'Where do you go?',
        definitionA: AdventureChoiceDefinition(
          id: 's3_bridge',
          optionText: 'CROSS THE BRIDGE',
          storedValue: 'CROSS THE BRIDGE',
          assetPath: AdventureAssets.mapBridge,
          mapLabel: 'BRIDGE',
          landmarkId: 'node_s3_bridge',
          normalizedPosition: Offset(0.56, 0.21),
          labelPosition: LabelPosition.below,
          icon: Icons.view_day_outlined,
        ),
        definitionB: AdventureChoiceDefinition(
          id: 's3_shelter',
          optionText: 'FIND SHELTER',
          storedValue: 'FIND SHELTER',
          assetPath: AdventureAssets.mapTreeLarge,
          mapLabel: 'SHELTER',
          landmarkId: 'node_s3_shelter',
          normalizedPosition: Offset(0.56, 0.21),
          labelPosition: LabelPosition.below,
          icon: Icons.holiday_village_outlined,
        ),
      ),
    ];
  }

  // ==================== PART 3: SHARED MOMENTS (3 Moments - Path B begins) ====================
  List<Chapter3Interaction> get chapter3Interactions =>
      _buildPersonalizedSharedMoments();

  List<Chapter3Interaction> _buildPersonalizedSharedMoments() {
    final q1 = rxSelectedChoices['q1'] ?? 'SUNRISE';
    final q3 = rxSelectedChoices['q3'] ?? 'TAKE LOTS OF PHOTOS';

    final isSunrise = q1 == 'SUNRISE';
    final isPhotos = q3 == 'TAKE LOTS OF PHOTOS';

    return [
      // M1: The First Morning (Path B Emerges on upper east slope)
      Chapter3Interaction(
        index: 1,
        id: 'chapter3_q1',
        title: 'THE FIRST MORNING',
        promptLine1: isSunrise
            ? 'You wake up early.'
            : 'You wake up with no alarms or plans for the day.',
        promptLine2: isSunrise
            ? 'The morning light is just starting to show.'
            : "It's calm and quiet.",
        promptLine3:
            "Someone beside you whispers:\n'Five more minutes?'",
        definitionA: const AdventureChoiceDefinition(
          id: 'm1_explore',
          optionText: "LET'S EXPLORE",
          storedValue: "LET'S EXPLORE",
          assetPath: AdventureAssets.mapMountain,
          mapLabel: 'MOUNTAIN VIEW',
          landmarkId: 'node_m1_mountain',
          normalizedPosition: Offset(0.72, 0.26),
          isPathB: true,
          labelPosition: LabelPosition.right,
          icon: Icons.wb_sunny_outlined,
        ),
        definitionB: const AdventureChoiceDefinition(
          id: 'm1_slow',
          optionText: 'FIVE MORE MINUTES',
          storedValue: 'FIVE MORE MINUTES',
          assetPath: AdventureAssets.expMoon,
          mapLabel: 'SLOW MORNING',
          landmarkId: 'node_m1_slow',
          normalizedPosition: Offset(0.72, 0.26),
          isPathB: true,
          labelPosition: LabelPosition.right,
          icon: Icons.nights_stay_outlined,
        ),
      ),

      // M2: Come Look (Path B Extends down eastern slope)
      const Chapter3Interaction(
        index: 2,
        id: 'chapter3_q2',
        title: 'COME LOOK',
        promptLine1: "You're walking along the path together.",
        promptLine2: 'Someone suddenly stops and points off the trail.',
        promptLine3: "'Come look at this.'",
        definitionA: AdventureChoiceDefinition(
          id: 'm2_campfire',
          optionText: 'GO SEE',
          storedValue: 'GO SEE',
          assetPath: AdventureAssets.expCampfire,
          mapLabel: 'CAMPFIRE',
          landmarkId: 'node_m2_campfire',
          normalizedPosition: Offset(0.68, 0.48),
          isPathB: true,
          labelPosition: LabelPosition.right,
          icon: Icons.local_fire_department_outlined,
        ),
        definitionB: AdventureChoiceDefinition(
          id: 'm2_lookout',
          optionText: 'KEEP WALKING',
          storedValue: 'KEEP WALKING',
          assetPath: AdventureAssets.expStars,
          mapLabel: 'LOOKOUT',
          landmarkId: 'node_m2_lookout',
          normalizedPosition: Offset(0.68, 0.48),
          isPathB: true,
          labelPosition: LabelPosition.right,
          icon: Icons.stars_outlined,
        ),
      ),

      // M3: What You Remember (Dual paths approach)
      Chapter3Interaction(
        index: 3,
        id: 'chapter3_q3',
        title: 'WHAT YOU REMEMBER',
        promptLine1: isPhotos
            ? "Imagine the trip is over and you're looking through all your photos."
            : "Imagine the trip is over and you're thinking back on everything.",
        promptLine2:
            'Months from now, what will you remember most?',
        promptLine3: null,
        definitionA: const AdventureChoiceDefinition(
          id: 'm3_place',
          optionText: 'THE PLACE',
          storedValue: 'THE PLACE',
          assetPath: AdventureAssets.expDiscoveryMarker,
          mapLabel: 'DISCOVERY',
          landmarkId: 'node_m3_place',
          normalizedPosition: Offset(0.38, 0.68),
          isPathB: false,
          labelPosition: LabelPosition.left,
          icon: Icons.landscape_outlined,
        ),
        definitionB: const AdventureChoiceDefinition(
          id: 'm3_shared',
          optionText: 'WHO I WAS WITH',
          storedValue: 'WHO I WAS WITH',
          assetPath: AdventureAssets.expCampfire,
          mapLabel: 'CAMPFIRE',
          landmarkId: 'node_m3_shared',
          normalizedPosition: Offset(0.62, 0.68),
          isPathB: true,
          labelPosition: LabelPosition.right,
          icon: Icons.people_outline_rounded,
        ),
      ),
    ];
  }

  Chapter1Question get currentQuestion =>
      chapter1Questions[rxCurrentQuestionIndex.value];

  Chapter2Situation get currentSituation =>
      chapter2Situations[rxCurrentSituationIndex.value];

  Chapter3Interaction get currentInteraction =>
      chapter3Interactions[rxCurrentInteractionIndex.value];

  bool get isCurrentOptionSelected =>
      rxSelectedCurrentOption.value.isNotEmpty;

  // ==================== LIFECYCLE ====================
  @override
  void onInit() {
    super.onInit();
    _initAnimation();
    _initStartingMapElements();
  }

  @override
  void onClose() {
    mapAnimController.dispose();
    super.onClose();
  }

  void _initAnimation() {
    mapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    mapProgressAnimation = CurvedAnimation(
      parent: mapAnimController,
      curve: Curves.easeOutCubic,
    );

    mapAnimController.addListener(() {
      rxPathAnimationProgress.value = mapProgressAnimation.value;
    });
  }

  void _initStartingMapElements() {
    // Starting base point (Origin with compass at lower-left with safe margins matching reference image)
    rxMapNodes.assignAll([
      const MapLandmarkNode(
        id: 'start_origin',
        assetPath: AdventureAssets.mapCompass,
        label: 'START',
        normalizedPosition: Offset(0.18, 0.88),
        size: 34.0,
        stepRevealed: 0,
        showLabel: true,
        isPrimary: true,
        labelPosition: LabelPosition.right,
      ),
    ]);
  }

  // ==================== PART 1 ACTIONS ====================

  void startAdventure() {
    rxChapter.value = AdventureChapter.chapter1;
    rxCurrentQuestionIndex.value = 0;
    rxSelectedCurrentOption.value = '';
    rxIsAdvancing.value = false;
  }

  Future<void> selectOption(String option) async {
    if (rxIsAdvancing.value) return;

    rxIsAdvancing.value = true;
    rxSelectedCurrentOption.value = option;
    final currentQ = currentQuestion;
    rxSelectedChoices[currentQ.id] = option;

    final isOptionA = option == currentQ.optionA;
    final definition =
        isOptionA ? currentQ.definitionA : currentQ.definitionB;

    // Dynamically evolve the map for Part 1
    _addMapElementsForPart1(currentQ.id, definition);

    // Run the path animation
    mapAnimController.reset();
    mapAnimController.forward();

    await Future.delayed(const Duration(milliseconds: 550));

    if (rxCurrentQuestionIndex.value < chapter1Questions.length - 1) {
      rxCurrentQuestionIndex.value++;
      rxSelectedCurrentOption.value = '';
      rxIsAdvancing.value = false;
    } else {
      rxChapter.value = AdventureChapter.chapter1Complete;
      rxIsAdvancing.value = false;
    }
  }

  void _addMapElementsForPart1(
      String questionId, AdventureChoiceDefinition definition) {
    final prevEnd = rxPathSegments.isNotEmpty
        ? rxPathSegments.last.end
        : const Offset(0.18, 0.88);

    final endPos = definition.normalizedPosition;

    switch (questionId) {
      case 'q1':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.19, 0.81),
            control2: const Offset(0.22, 0.76),
            end: endPos,
            isWinding: true,
            step: 1,
          ),
        );
        break;

      case 'q2':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.24, 0.65),
            control2: const Offset(0.21, 0.60),
            end: endPos,
            step: 2,
          ),
        );
        break;

      case 'q3':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.22, 0.48),
            control2: const Offset(0.25, 0.43),
            end: endPos,
            isWinding: true,
            step: 3,
          ),
        );
        break;
    }

    rxMapNodes.add(
      definition.toMapNode(
        stepRevealed: rxCurrentQuestionIndex.value + 1,
        size: 30.0,
      ),
    );
  }

  void onContinueChapter1() {
    rxChapter.value = AdventureChapter.chapter2Intro;
  }

  // ==================== PART 2 ACTIONS ====================

  void startChapter2() {
    rxChapter.value = AdventureChapter.chapter2;
    rxCurrentSituationIndex.value = 0;
    rxSelectedCurrentOption.value = '';
    rxIsAdvancing.value = false;
  }

  Future<void> selectSituationDecision(String decision) async {
    if (rxIsAdvancing.value) return;

    rxIsAdvancing.value = true;
    rxSelectedCurrentOption.value = decision;
    final currentSit = currentSituation;
    rxSelectedChoices[currentSit.id] = decision;

    final isOptionA = decision == currentSit.optionA;
    final definition =
        isOptionA ? currentSit.definitionA : currentSit.definitionB;

    // Dynamically evolve the map for Part 2
    _addMapElementsForPart2(currentSit.id, definition);

    // Run the path animation
    mapAnimController.reset();
    mapAnimController.forward();

    await Future.delayed(const Duration(milliseconds: 550));

    if (rxCurrentSituationIndex.value < chapter2Situations.length - 1) {
      rxCurrentSituationIndex.value++;
      rxSelectedCurrentOption.value = '';
      rxIsAdvancing.value = false;
    } else {
      rxChapter.value = AdventureChapter.chapter2Complete;
      rxIsAdvancing.value = false;
    }
  }

  void _addMapElementsForPart2(
      String situationId, AdventureChoiceDefinition definition) {
    final primarySegments =
        rxPathSegments.where((s) => !s.isSecondaryPath).toList();
    final prevEnd = primarySegments.isNotEmpty
        ? primarySegments.last.end
        : const Offset(0.28, 0.38);

    final endPos = definition.normalizedPosition;

    switch (situationId) {
      case 'chapter2_q1':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.29, 0.34),
            control2: const Offset(0.30, 0.30),
            end: endPos,
            isWinding: true,
            step: 4,
          ),
        );
        break;

      case 'chapter2_q2':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.34, 0.24),
            control2: const Offset(0.38, 0.21),
            end: endPos,
            step: 5,
          ),
        );
        break;

      case 'chapter2_q3':
        rxPathSegments.add(
          MapRouteSegment(
            start: prevEnd,
            control1: const Offset(0.47, 0.19),
            control2: const Offset(0.52, 0.20),
            end: endPos,
            isWinding: true,
            step: 6,
          ),
        );
        break;
    }

    rxMapNodes.add(
      definition.toMapNode(
        stepRevealed: rxCurrentSituationIndex.value + 4,
        size: 30.0,
      ),
    );
  }

  void onContinueChapter2() {
    rxChapter.value = AdventureChapter.chapter3Intro;
  }

  // ==================== PART 3 ACTIONS ====================

  void startChapter3() {
    rxChapter.value = AdventureChapter.chapter3;
    rxCurrentInteractionIndex.value = 0;
    rxSelectedCurrentOption.value = '';
    rxIsAdvancing.value = false;
  }

  Future<void> selectInteractionChoice(String choice) async {
    if (rxIsAdvancing.value) return;

    rxIsAdvancing.value = true;
    rxSelectedCurrentOption.value = choice;
    final currentInter = currentInteraction;
    rxSelectedChoices[currentInter.id] = choice;

    final isOptionA = choice == currentInter.optionA;
    final definition =
        isOptionA ? currentInter.definitionA : currentInter.definitionB;

    // Dynamically evolve the map for Part 3
    _addMapElementsForPart3(currentInter.id, definition);

    // Run the path animation
    mapAnimController.reset();
    mapAnimController.forward();

    await Future.delayed(const Duration(milliseconds: 550));

    if (rxCurrentInteractionIndex.value < chapter3Interactions.length - 1) {
      rxCurrentInteractionIndex.value++;
      rxSelectedCurrentOption.value = '';
      rxIsAdvancing.value = false;
    } else {
      rxChapter.value = AdventureChapter.chapter3Complete;
      rxIsAdvancing.value = false;
    }
  }

  void _addMapElementsForPart3(
      String interactionId, AdventureChoiceDefinition definition) {
    final primarySegments =
        rxPathSegments.where((s) => !s.isSecondaryPath).toList();
    final primaryEnd = primarySegments.isNotEmpty
        ? primarySegments.last.end
        : const Offset(0.56, 0.21);

    final secondarySegments =
        rxPathSegments.where((s) => s.isSecondaryPath).toList();
    final secondaryEnd = secondarySegments.isNotEmpty
        ? secondarySegments.last.end
        : const Offset(0.86, 0.22);

    switch (interactionId) {
      case 'chapter3_q1':
        // M1: The First Morning (Path B Emerges at upper east slope 0.86, 0.22)
        const pathBStart = Offset(0.86, 0.22);
        const pathBEnd = Offset(0.72, 0.26);
        rxPathSegments.add(
          const MapRouteSegment(
            start: pathBStart,
            control1: Offset(0.81, 0.23),
            control2: Offset(0.76, 0.25),
            end: pathBEnd,
            isWinding: true,
            step: 7,
            isSecondaryPath: true,
          ),
        );
        rxMapNodes.add(
          definition.toMapNode(stepRevealed: 7, size: 30.0),
        );
        break;

      case 'chapter3_q2':
        // M2: Come Look (Path B Extends down right side to 0.68, 0.48)
        const endPos = Offset(0.68, 0.48);
        rxPathSegments.add(
          MapRouteSegment(
            start: secondaryEnd,
            control1: const Offset(0.72, 0.34),
            control2: const Offset(0.70, 0.42),
            end: endPos,
            isWinding: true,
            step: 8,
            isSecondaryPath: true,
          ),
        );
        rxMapNodes.add(
          definition.toMapNode(stepRevealed: 8, size: 30.0),
        );
        break;

      case 'chapter3_q3':
        // M3: What You Remember (Both paths approach pre-convergence)
        // Path A -> (0.38, 0.68)
        // Path B -> (0.62, 0.68)
        const targetPathAEnd = Offset(0.38, 0.68);
        const targetPathBEnd = Offset(0.62, 0.68);

        // Extend Path A
        rxPathSegments.add(
          MapRouteSegment(
            start: primaryEnd,
            control1: const Offset(0.50, 0.36),
            control2: const Offset(0.42, 0.52),
            end: targetPathAEnd,
            isWinding: true,
            step: 9,
            isSecondaryPath: false,
          ),
        );

        // Extend Path B
        rxPathSegments.add(
          MapRouteSegment(
            start: secondaryEnd,
            control1: const Offset(0.67, 0.56),
            control2: const Offset(0.65, 0.62),
            end: targetPathBEnd,
            isWinding: false,
            step: 9,
            isSecondaryPath: true,
          ),
        );

        // Add node for chosen memory
        rxMapNodes.add(
          definition.toMapNode(stepRevealed: 9, size: 30.0),
        );
        break;
    }
  }

  // ==================== CLIMAX: CONVERGENCE & REVEAL ====================

  void onContinueChapter3() {
    startRevealSequence();
  }

  Future<void> startRevealSequence() async {
    _addConvergenceElements();

    rxChapter.value = AdventureChapter.revealConvergence;

    // 1. MAP EXPANDS (0.0s - 1.2s): Map opens to fullscreen, UI collapses
    rxRevealStage.value = RevealStage.expanding;
    rxCompassNormalizedY.value = 0.82;
    rxTrailOpacity.value = 1.0;
    rxPathMergeProgress.value = 0.0;
    rxShowUnifiedPath.value = false;
    rxUnifiedPathProgress.value = 0.0;
    await Future.delayed(const Duration(milliseconds: 1200));

    // 2. PATHS MEET (1.2s - 2.8s): The two existing trails travel and meet at compass
    rxRevealStage.value = RevealStage.pathsMerging;
    const mergeDurationMs = 1600;
    const mergeSteps = 32;
    final mergeInterval = (mergeDurationMs / mergeSteps).round();
    for (int i = 1; i <= mergeSteps; i++) {
      await Future.delayed(Duration(milliseconds: mergeInterval));
      rxPathMergeProgress.value = i / mergeSteps;
    }
    rxPathMergeProgress.value = 1.0;
    // STOP: Brief pause after they meet so convergence is clearly registered
    await Future.delayed(const Duration(milliseconds: 400));

    // 3. COMPASS RISES & PATHS MERGE INTO ONE (2.8s - 4.0s):
    // Compass rises upward from 0.82 to 0.45 (close to YOU.); two paths merge into single glowing curved path
    rxRevealStage.value = RevealStage.compassRising;
    rxShowUnifiedPath.value = true;
    const riseDurationMs = 1200;
    const riseSteps = 30;
    final riseInterval = (riseDurationMs / riseSteps).round();
    for (int i = 1; i <= riseSteps; i++) {
      await Future.delayed(Duration(milliseconds: riseInterval));
      final double fraction = i / riseSteps;
      rxCompassNormalizedY.value = 0.82 - (0.37 * fraction); // 0.82 -> 0.45
      rxUnifiedPathProgress.value = fraction;
      rxTrailOpacity.value = (1.0 - fraction).clamp(0.0, 1.0);
    }
    rxCompassNormalizedY.value = 0.45;
    rxUnifiedPathProgress.value = 1.0;
    rxTrailOpacity.value = 0.0;
    // Transform complete: Single unified curved path established before text starts!
    await Future.delayed(const Duration(milliseconds: 400));

    // 4. FIRST THOUGHT (4.0s - 5.4s): First sentence appears and stays
    rxChapter.value = AdventureChapter.revealText;
    rxRevealTextStep.value = 1;
    rxRevealStage.value = RevealStage.firstThought;
    await Future.delayed(const Duration(milliseconds: 1500));

    // 5. SECOND THOUGHT (5.4s - 6.8s): Second sentence appears below, both stay
    rxRevealTextStep.value = 2;
    rxRevealStage.value = RevealStage.secondThought;
    await Future.delayed(const Duration(milliseconds: 1500));

    // 6. CLIMAX: "YOU." (6.8s - 8.6s): "YOU." appears prominently with warm golden aura
    rxChapter.value = AdventureChapter.revealYou;
    rxRevealStage.value = RevealStage.youClimax;
    await Future.delayed(const Duration(milliseconds: 1800));

    // 7. HOLD MOMENT (8.6s - 10.6s): 2-second hold of complete composition
    rxRevealStage.value = RevealStage.holdMoment;
    await Future.delayed(const Duration(milliseconds: 2000));

    // 8. INVITATION (10.6s onward): Frosted invitation panel rises smoothly from bottom
    rxChapter.value = AdventureChapter.invitationReady;
    rxRevealStage.value = RevealStage.invitationCard;
  }

  void _addConvergenceElements() {
    // 1. Extend Path A from (0.38, 0.68) to converge at destination (0.50, 0.82)
    rxPathSegments.add(
      const MapRouteSegment(
        start: Offset(0.38, 0.68),
        control1: Offset(0.42, 0.74),
        control2: Offset(0.46, 0.79),
        end: Offset(0.50, 0.82),
        isWinding: false,
        step: 10,
        isSecondaryPath: false,
      ),
    );

    // 2. Extend Path B from (0.62, 0.68) to converge at destination (0.50, 0.82)
    rxPathSegments.add(
      const MapRouteSegment(
        start: Offset(0.62, 0.68),
        control1: Offset(0.58, 0.74),
        control2: Offset(0.54, 0.79),
        end: Offset(0.50, 0.82),
        isWinding: false,
        step: 10,
        isSecondaryPath: true,
      ),
    );

    // 3. Reveal Final Destination Landmark at exact convergence point
    rxMapNodes.add(
      const MapLandmarkNode(
        id: 'node_final_destination',
        assetPath: AdventureAssets.revealFinalMarker,
        label: 'DESTINATION',
        normalizedPosition: Offset(0.50, 0.82),
        size: 44.0,
        stepRevealed: 10,
        showLabel: true,
        isPrimary: true,
        labelPosition: LabelPosition.below,
      ),
    );
  }

  /// Handle selection for final invitation choices (YES, LET'S GO / TELL ME MORE)
  Future<void> selectInvitationOption(String option) async {
    if (rxIsAdvancing.value) return;
    rxIsAdvancing.value = true;
    rxSelectedInvitationResponse.value = option;
    rxSelectedChoices['invitation_response'] = option;

    await Future.delayed(const Duration(milliseconds: 400));

    try {
      await _performChatHandoff(option);
    } catch (e) {
      rxIsAdvancing.value = false;
      if (Get.overlayContext != null) {
        Get.snackbar(
          'Notice',
          'Failed to open conversation: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColorHelper.cardSurface,
          colorText: AppColorHelper.darkText,
          borderRadius: 12,
          borderWidth: 1,
          borderColor: AppColorHelper.borderTeal,
        );
      }
    }
  }

  Future<void> _performChatHandoff(String option) async {
    String chatId = '';
    if (Get.isRegistered<ChatService>()) {
      final chatService = Get.find<ChatService>();
      if (chatService.isAuthenticated) {
        chatId = await chatService.prepareAdventureChatRoom(
          invitationResponse: option,
          adventureChoices: Map<String, String>.from(rxSelectedChoices),
          mapNodes: rxMapNodes.toList(),
          mapSegments: rxPathSegments.toList(),
        );
      }
    }

    // Navigate to ChatScreen reusing existing chatPageRoute and ChatArguments
    Get.offNamed(
      chatPageRoute,
      arguments: {'chatId': chatId, 'isAdmin': false},
    );
  }
}

