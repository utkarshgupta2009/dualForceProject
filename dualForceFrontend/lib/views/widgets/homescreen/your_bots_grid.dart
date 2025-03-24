import 'package:dual_force/utils/navigation/routes/slide_route.dart';
import 'package:dual_force/viewmodels/auth_viewmodel.dart';
import 'package:dual_force/views/screens/chatting_screen/chatting_screen.dart';
import 'package:dual_force/views/widgets/homescreen/feature_card.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:provider/provider.dart';

class YourBotsGrid extends StatefulWidget {
  const YourBotsGrid({Key? key}) : super(key: key);

  @override
  State<YourBotsGrid> createState() => _YourBotsGridState();
}

class _YourBotsGridState extends State<YourBotsGrid> {
  //late List<ExpertSystem> _bots;
  String? _error;

  // @override
  // void initState() {
  //   super.initState();
  //   _getBots();
  // }

  // Future<void> _getBots() async {
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //    _bots =  Provider.of<AuthViewmodel>(context, listen: false)
  //         .currentUser
  //         ?.expertSystems??[];

  //     if (mounted) {
  //       setState(() {
  //         //   _bots = bots;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _error = e.toString();
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Bots', style: AppTextStyle.largeTextStyle),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Text(
          'Error loading bots: $_error',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Consumer<AuthViewmodel>(builder: (context, viewModel, child) {
      if (viewModel.currentUser == null ||
          viewModel.currentUser!.expertSystems.isEmpty) {
        return const Center(
          child: Text(
            'No Expert Systems found\nCreate a new one by clicking below button',
            style: AppTextStyle.mediumTextStyle,
          ),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: viewModel.currentUser?.expertSystems.length ?? 0,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final expertSystem = viewModel.currentUser!.expertSystems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                SlideRoute(
                  page: ChatScreen(
                    expertSystem: expertSystem,
                  ),
                ),
              );
            },
            child: FeatureCard(
              title: expertSystem.name,
              description: expertSystem.description,
              icon: Icons.computer,
              iconColor: Colors.blue,
            ),
          );
        },
      );
    });
  }
}
