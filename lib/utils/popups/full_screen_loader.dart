import 'package:storyapp/utils/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storyapp/common/widgets/loaders/animation_loader.dart';
import 'package:storyapp/utils/constraints/colors.dart';
import 'package:storyapp/utils/helpers/helper_functions.dart';

///a utility class for managing full screen loading dialog

class TFullScreenLoader {
  ///open a full screen loading dialog with a given text and animation

  static void openLoadingDialog(String text, String animation) {
    showDialog(
        context: Get.overlayContext!, // use this for overlay dialogs
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async {return false;},
          child: Container(
            color: THelperFunctions.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 250), //adjust space as needed
                TAnimationLoaderWidget(text: text, animation: animation),
              ],
            ),
          ),
        ),
    );
    TLoggerHelper.info('Loading dialog opened');
  }

  ///stop the currently loading open dialog
  static stopLoading() {
    Get.back(); // GetX handles overlay context automatically
    TLoggerHelper.info('Loading dialog closed');// clos// e dialog using navigator
  }
}