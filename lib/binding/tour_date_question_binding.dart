// tour_date_question_binding.dart
// Tour Date Question Binding - Dependency injection for Tour Date Question Screen
// Follows Agro-Prod patterns: implements Bindings, uses lazyPut with fenix

import 'package:get/get.dart';

import '../controller/tour_date_question_controller.dart';

class TourDateQuestionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TourDateQuestionController>(
      () => TourDateQuestionController(),
      fenix: true,
    );
  }
}
