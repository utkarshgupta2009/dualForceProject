import 'dart:developer';

import 'package:dual_force/utils/navigation/routes/slide_route.dart';
import 'package:dual_force/utils/pdf_viewer.dart';
import 'package:dual_force/viewmodels/auth_viewmodel.dart';
import 'package:dual_force/views/screens/books_screen/book_search_screen.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_button.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/abstarct_layer/stack_abstract_view.dart';
import 'package:dual_force/abstarct_layer/stack_item_model.dart';
import 'package:dual_force/flutter_gen_asset/gen/assets.gen.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:dual_force/viewmodels/create_bot_viewmodel.dart';
import 'package:provider/provider.dart';

class CreateBotScreen extends StatefulWidget {
  const CreateBotScreen({super.key});

  @override
  _CreateBotScreenState createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen>
    implements StackAbstractView<CreateBotViewmodel> {
  @override
  void initState() {
    super.initState();
    configureView();
    initializeView(context);
  }

  @override
  void configureView() {
    // Any additional configuration can be added here
    // For example, setting up initial state, registering listeners, etc.
  }

  @override
  void initializeView(BuildContext context) {
    final viewmodel = Provider.of<CreateBotViewmodel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewmodel.fetchStackItems();
    });
  }

  @override
  void handleBackNavigation(
      BuildContext context, CreateBotViewmodel viewModel) {
    final expandedIndex =
        viewModel.currentStackItems.indexWhere((item) => item.isExpanded);

    if (expandedIndex > 0) {
      viewModel.removeCurrentExpandedItem(expandedIndex);
    }
  }

  @override
  bool canNavigateBack(BuildContext context, CreateBotViewmodel viewModel) {
    return viewModel.currentStackItems.length == 1;
  }

  @override
  Widget buildErrorView(BuildContext context, dynamic error) {
    return defaultErrorView(context, error);
  }

  @override
  Widget buildLoadingView(BuildContext context) {
    return defaultLoadingView(context);
  }

  void viewPDF(BuildContext context, String pdfUrl, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          pdfUrl: pdfUrl,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  Widget buildView(BuildContext context, CreateBotViewmodel viewModel) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                    maxRadius: 15,
                    backgroundColor: AppColors.themeColors2[0],
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    )),
              ),
              CircleAvatar(
                  maxRadius: 15,
                  backgroundColor: AppColors.themeColors2[0],
                  child: Icon(
                    Icons.question_mark,
                    color: Colors.white,
                    size: 14,
                  )),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: List.generate(
              viewModel.currentStackItems.length,
              (index) {
                final item = viewModel.currentStackItems[index];

                final offset = index * 100.0;

                return Positioned(
                  top: offset,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => viewModel.toggleItemExpansion(index),
                    child: item.isExpanded
                        ? buildExpandedView(
                            item, index, viewModel, deviceHeight, deviceWidth)
                        : buildCollapsedView(item, index, viewModel),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildExpandedView(StackItemModel item, int index,
      CreateBotViewmodel viewmodel, double deviceHeight, double deviceWidth) {
    final openState = item.openState.body;
    return Container(
      // padding: const EdgeInsets.only(top: 16),
      constraints: BoxConstraints(
        maxWidth: deviceWidth - 40, // Account for horizontal margins
      ),
      decoration: BoxDecoration(
        color: AppColors.themeColors2[index],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min, // Use minimum space necessary
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      openState.title ?? '',
                      style: AppTextStyle.titleTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      openState.subtitle ?? '',
                      maxLines: 3,
                      style: AppTextStyle.subtitleTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (index == 0) _buildUploadDocumentSection(viewmodel),
              if (index == 1) _buildExpertSystemNamingSection(viewmodel),
              if (index == 2) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name :-",
                      style: AppTextStyle.titleSmallTextStyle,
                    ),
                    Text(
                      viewmodel.nameController.text,
                      style: AppTextStyle.largeTextStyle,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Description :-",
                      style: AppTextStyle.titleSmallTextStyle,
                    ),
                    Text(
                      viewmodel.descriptionController.text,
                      style: AppTextStyle.largeTextStyle,
                    ),
                    if (viewmodel.uploadedFileUrl != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColors1[2]),
                        onPressed: () => viewPDF(
                          context,
                          viewmodel.uploadedFileUrl!,
                          viewmodel.fileName ?? 'document.pdf',
                        ),
                        icon: const Icon(
                          Icons.visibility,
                          color: AppColors.textColor,
                        ),
                        label: const Text(
                          'View PDF',
                          style: AppTextStyle.mediumTextStyle,
                        ),
                      ),
                    ],
                  ],
                )
              ]
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 60,
              width: deviceWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    backgroundColor: AppColors.themeColors1[0],
                    foregroundColor: Colors.white),
                onPressed: () async {
                  try {
                    final userId =
                        Provider.of<AuthViewmodel>(context, listen: false)
                                .currentUser
                                ?.id ??
                            "";
                    await viewmodel
                        .getCtaOnPressed(index, viewmodel, userId)
                        .then((val) {
                      if (index == 2 &&
                          viewmodel.newlyCreatedExpertSystem != null) {
                        Provider.of<AuthViewmodel>(context, listen: false)
                            .addExpertSystem(
                                viewmodel.newlyCreatedExpertSystem!);
                      }
                    });
                  } catch (e) {
                    log(e.toString());
                  } finally {
                    if (index == 2) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(
                  item.ctaText,
                  style: AppTextStyle.titleSmallTextStyle
                      .copyWith(color: Colors.white.withAlpha(200)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCollapsedView(
      StackItemModel item, int index, CreateBotViewmodel viewmodel) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.themeColors2[index],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // Add Expanded to constrain width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0)
                  _buildCollapsedHeader(
                    item.closedState.title ?? '',
                    viewmodel.fileName ?? '',
                  ),
                if (index == 1)
                  _buildCollapsedHeader(
                    item.closedState.title ?? '',
                    viewmodel.nameController.text,
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.titleSecondaryTextStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
            height: 4), // Add some spacing between title and subtitle
        ConstrainedBox(
          // Constrain the width of the subtitle
          constraints: BoxConstraints(
              maxWidth: 280), // Adjust this value based on your needs
          child: Text(
            subtitle,
            style: AppTextStyle.titleSecondaryTextStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDocumentSection(CreateBotViewmodel viewModel) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => viewModel.pickFile(),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.textColor, width: 1.5),
              ),
              child: Column(
                children: [
                  Assets.svgs.uploadIcon.svg(
                    height: 100,
                    color: AppColors.textColor.withAlpha(200),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.isFileSelected
                        ? viewModel.fileName ?? "File selected"
                        : "Tap to upload PDF or DOCX",
                    style: AppTextStyle.mediumTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (viewModel.uploadedFileUrl != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColors1[2]),
            onPressed: () => viewPDF(
              context,
              viewModel.uploadedFileUrl!,
              viewModel.fileName ?? 'document.pdf',
            ),
            icon: const Icon(
              Icons.visibility,
              color: AppColors.textColor,
            ),
            label: const Text(
              'View PDF',
              style: AppTextStyle.mediumTextStyle,
            ),
          ),
        ],
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 250,
          child: CustomButton(
              icon: null,
              label: Text(
                "Search for books Online",
                style: AppTextStyle.mediumTextStyleBlack,
              ),
              onPressed: () {
                Navigator.push(context, SlideRoute(page: BookSearchScreen()));
              }),
        )
      ],
    );
  }

  Widget _buildExpertSystemNamingSection(CreateBotViewmodel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
                controller: viewModel.nameController, hintText: 'Enter a name'),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: viewModel.descriptionController,
              hintText: 'Give a description',
              maxLines: 4,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateBotViewmodel>(builder: (context, viewModel, child) {
      return PopScope(
        canPop: canNavigateBack(context, viewModel),
        onPopInvokedWithResult: (didPop, res) {
          if (didPop) return;

          handleBackNavigation(context, viewModel);
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: _mainContent(viewModel),
          ),
        ),
      );
    });
  }

  Widget _mainContent(CreateBotViewmodel viewModel) {
    if (viewModel.isLoading) {
      return buildLoadingView(context);
    }

    if (viewModel.error != null) {
      return buildErrorView(context, viewModel.error);
    }

    return buildView(context, viewModel);
  }
}
