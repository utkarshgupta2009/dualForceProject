import 'package:dual_force/views/widgets/homescreen/your_bots_grid.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:dual_force/utils/navigation/routes/slide_route.dart';
import 'package:dual_force/views/screens/create_bot_screen/create_bot_screen.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_textfield.dart';

class Homescreen extends StatelessWidget {
  final String userId;
  const Homescreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        ' DualForce',
                        style: AppTextStyle.largeTextStyle,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'search for bots or anything...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textColor,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.mic,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                 
                  const SizedBox(height: 16),
                  // YourBotsGrid(),
                  // const SizedBox(height: 16),
                  YourBotsGrid(),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 10,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context,
                    SlideRoute(
                        page: CreateBotScreen(),
                        direction: AxisDirection.right,
                        duration: Durations.long2));
              },
              icon: const Icon(
                Icons.add,
                color: AppColors.subtitleTextColor,
              ),
              label: const Text('Create New Bot',
                  style: AppTextStyle.subtitleTextStyle),
              backgroundColor: AppColors.primaryYellow,
            ),
          )
        ],
      ),
    );
  }

  
}
