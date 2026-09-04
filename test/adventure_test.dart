import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wanderlust/controller/adventure_controller.dart';
import 'package:wanderlust/helper/adventure_assets.dart';
import 'package:wanderlust/model/adventure_state_model.dart';
import 'package:wanderlust/model/response_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wanderlust 3+3+3 Story & Illustrated Map Tests', () {
    testWidgets('Initial State is Intro with start origin compass node',
        (WidgetTester tester) async {
      Get.reset();
      final controller = AdventureController();
      controller.onInit();

      expect(controller.rxChapter.value, equals(AdventureChapter.intro));
      expect(controller.rxCurrentQuestionIndex.value, equals(0));
      expect(controller.rxSelectedChoices.isEmpty, isTrue);
      expect(controller.rxMapNodes.length, equals(1));
      expect(controller.rxMapNodes.first.id, equals('start_origin'));

      controller.onClose();
      Get.reset();
    });

    testWidgets('Branch A: SUNRISE + PLAN THE WAY + TAKE LOTS OF PHOTOS',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        Get.testMode = true;
        Get.reset();
        final controller = AdventureController();
        controller.onInit();

        // 1. Chapter 1 (Instincts)
        controller.startAdventure();
        await controller.selectOption('SUNRISE');
        await controller.selectOption('PLAN THE WAY');
        await controller.selectOption('TAKE LOTS OF PHOTOS');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter1Complete));
        expect(controller.rxPathSegments.length, equals(3));
        expect(controller.rxMapNodes.length, equals(4)); // start + 3 nodes

        // Verify Chapter 2 is dynamically populated for Sunrise + Plan
        controller.onContinueChapter1();
        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter2Intro));
        controller.startChapter2();

        // 2. Chapter 2 (The Trail)
        expect(controller.currentSituation.promptLine1,
            equals('You have two hours before sunrise.'));
        await controller.selectSituationDecision('MAKE IT IN TIME');
        await controller.selectSituationDecision('TAKE THE RIDGE');
        await controller.selectSituationDecision('CROSS THE BRIDGE');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter2Complete));
        expect(controller.rxPathSegments.length, equals(6));
        expect(controller.rxMapNodes.length, equals(7));

        // 3. Chapter 3 (Shared Moments)
        controller.onContinueChapter2();
        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter3Intro));
        controller.startChapter3();

        await controller.selectInteractionChoice("LET'S EXPLORE");
        await controller.selectInteractionChoice('GO SEE');
        await controller.selectInteractionChoice('THE PLACE');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter3Complete));
        expect(controller.rxPathSegments.length, equals(10));
        expect(controller.rxMapNodes.length, equals(10));

        // 4. Reveal Convergence
        controller.onContinueChapter3();
        expect(controller.rxChapter.value,
            equals(AdventureChapter.revealConvergence));
        expect(controller.rxPathSegments.length, equals(12)); // 10 + 2 convergence
        expect(controller.rxMapNodes.length, equals(11)); // 10 + 1 destination

        // Destination convergence verification
        final destination = controller.rxMapNodes
            .firstWhere((n) => n.id == 'node_final_destination');
        expect(destination.normalizedPosition, equals(const Offset(0.50, 0.82)));

        controller.onClose();
        Get.reset();
      });
    });

    testWidgets('Branch B: SUNRISE + SEE WHERE IT GOES + KEEP THE MOMENT',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        Get.testMode = true;
        Get.reset();
        final controller = AdventureController();
        controller.onInit();

        // Chapter 1
        controller.startAdventure();
        await controller.selectOption('SUNRISE');
        await controller.selectOption('SEE WHERE IT GOES');
        await controller.selectOption('KEEP THE MOMENT');

        controller.onContinueChapter1();
        controller.startChapter2();

        // Verify Branch B narrative phrasing
        expect(controller.currentSituation.promptLine1,
            equals('You have two hours before sunrise.'));
        await controller.selectSituationDecision('TAKE THE LONG WAY');
        await controller.selectSituationDecision('FOLLOW THE TREES');
        await controller.selectSituationDecision('FIND SHELTER');

        controller.onContinueChapter2();
        controller.startChapter3();

        await controller.selectInteractionChoice('FIVE MORE MINUTES');
        await controller.selectInteractionChoice('KEEP WALKING');
        await controller.selectInteractionChoice('WHO I WAS WITH');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter3Complete));

        controller.onClose();
        Get.reset();
      });
    });

    testWidgets('Branch C: SUNSET + PLAN THE WAY + TAKE LOTS OF PHOTOS',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        Get.testMode = true;
        Get.reset();
        final controller = AdventureController();
        controller.onInit();

        // Chapter 1
        controller.startAdventure();
        await controller.selectOption('SUNSET');
        await controller.selectOption('PLAN THE WAY');
        await controller.selectOption('TAKE LOTS OF PHOTOS');

        controller.onContinueChapter1();
        controller.startChapter2();

        // Verify Sunset + Plan phrasing
        expect(controller.currentSituation.promptLine1,
            equals('You have two hours before sunset.'));
        await controller.selectSituationDecision('HURRY FOR THE VIEW');
        await controller.selectSituationDecision('TAKE THE RIDGE');
        await controller.selectSituationDecision('CROSS THE BRIDGE');

        controller.onContinueChapter2();
        controller.startChapter3();

        await controller.selectInteractionChoice("LET'S EXPLORE");
        await controller.selectInteractionChoice('GO SEE');
        await controller.selectInteractionChoice('THE PLACE');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter3Complete));

        controller.onClose();
        Get.reset();
      });
    });

    testWidgets('Branch D: SUNSET + SEE WHERE IT GOES + KEEP THE MOMENT',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        Get.testMode = true;
        Get.reset();
        final controller = AdventureController();
        controller.onInit();

        // Chapter 1
        controller.startAdventure();
        await controller.selectOption('SUNSET');
        await controller.selectOption('SEE WHERE IT GOES');
        await controller.selectOption('KEEP THE MOMENT');

        controller.onContinueChapter1();
        controller.startChapter2();

        // Verify Sunset + See Where It Goes phrasing
        expect(controller.currentSituation.promptLine1,
            equals('You have two hours before sunset.'));
        await controller.selectSituationDecision('TAKE THE LONG WAY');
        await controller.selectSituationDecision('FOLLOW THE TREES');
        await controller.selectSituationDecision('FIND SHELTER');

        controller.onContinueChapter2();
        controller.startChapter3();

        await controller.selectInteractionChoice('FIVE MORE MINUTES');
        await controller.selectInteractionChoice('KEEP WALKING');
        await controller.selectInteractionChoice('WHO I WAS WITH');

        expect(controller.rxChapter.value,
            equals(AdventureChapter.chapter3Complete));

        // Test Invitation Choice
        controller.onContinueChapter3();
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.selectInvitationOption("YES, LET'S GO");
        expect(controller.rxSelectedInvitationResponse.value,
            equals("YES, LET'S GO"));

        controller.onClose();
        Get.reset();
      });
    });

    testWidgets('ResponseModel serialization & Admin Map reconstruction',
        (WidgetTester tester) async {
      Get.testMode = true;
      Get.reset();

      final sampleNodes = [
        const MapLandmarkNode(
          id: 'start_origin',
          assetPath: AdventureAssets.landmarkStartCompass,
          label: 'START',
          normalizedPosition: Offset(0.18, 0.88),
          stepRevealed: 0,
        ),
        const MapLandmarkNode(
          id: 'node_final_destination',
          assetPath: AdventureAssets.landmarkDestinationCompass,
          label: 'DESTINATION',
          normalizedPosition: Offset(0.50, 0.82),
          stepRevealed: 9,
        ),
      ];

      final sampleSegments = [
        const MapRouteSegment(
          start: Offset(0.18, 0.88),
          control1: Offset(0.24, 0.80),
          control2: Offset(0.38, 0.80),
          end: Offset(0.50, 0.82),
          step: 1,
        ),
      ];

      final sampleData = {
        'userId': 'traveler_123',
        'email': 'traveler@gmail.com',
        'answers': ['Adventure Choice: YES, LET\'S GO'],
        'adventureCompleted': true,
        'invitationResponse': "YES, LET'S GO",
        'adventureChoices': {
          'd1': 'SUNRISE',
          'd2': 'PLAN THE WAY',
          'd3': 'TAKE LOTS OF PHOTOS',
        },
        'adventureMap': {
          'nodes': sampleNodes.map((n) => n.toJson()).toList(),
          'segments': sampleSegments.map((s) => s.toJson()).toList(),
        },
      };

      final response = ResponseModel.fromFirestore(sampleData, 'traveler_123');
      expect(response.adventureCompleted, isTrue);
      expect(response.invitationResponse, equals("YES, LET'S GO"));
      expect(response.mapNodes.length, equals(2));
      expect(response.mapSegments.length, equals(1));

      // Test toFirestore serialization
      final firestoreData = response.toFirestore();
      expect(firestoreData['adventureCompleted'], isTrue);
      expect(firestoreData['invitationResponse'], equals("YES, LET'S GO"));
      expect((firestoreData['adventureMap']['nodes'] as List).length, equals(2));
      expect((firestoreData['adventureMap']['segments'] as List).length, equals(1));

      Get.reset();
    });
  });
}
