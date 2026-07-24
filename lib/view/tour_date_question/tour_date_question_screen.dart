import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/tour_date_question_controller.dart';
import '../../helper/core/base/app_base_view.dart';

class TourDateQuestionScreen extends AppBaseView<TourDateQuestionController> {
  const TourDateQuestionScreen({super.key});

  @override
  Widget buildView() => _widgetView();

  Widget _widgetView() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tour Questionnaire'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: controller.logout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () => PageView.builder(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.questions.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.questions[index],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (val) =>
                          controller.onAnswerChanged(index, val),
                      decoration: const InputDecoration(
                        hintText: 'Type your answer...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (index > 0)
                          ElevatedButton(
                            onPressed: controller.previousPage,
                            child: const Text('Go Back'),
                          ),
                        ElevatedButton(
                          onPressed: controller.nextPage,
                          child: Text(
                            index == controller.questions.length - 1
                                ? 'Finish'
                                : 'Continue',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
