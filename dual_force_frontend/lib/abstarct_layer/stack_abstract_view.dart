import 'package:flutter/material.dart';
import 'package:dual_force/abstarct_layer/stack_abstarct_viewmodel.dart';
import 'package:dual_force/abstarct_layer/stack_item_model.dart';

/// [T] is the type of ViewModel used in the implementation
/// Provides a flexible and extensible approach to creating stack-based user interfaces
abstract class StackAbstractView<T extends StackAbstractViewmodel> {
  /// Builds the main structure of the view
  ///
  /// [context] The build context for rendering
  /// [viewModel] The view model controlling the view's state and logic
  /// Returns the primary widget representing the entire view
  Widget buildView(BuildContext context, T viewModel);

  /// Constructs the expanded state of a stack item
  ///
  /// [item] The current stack item to be rendered in expanded state
  /// [index] The position of the item in the stack
  /// [viewModel] The view model controlling the view's state
  /// [deviceHeight] Total height of the device screen
  /// [deviceWidth] Total width of the device screen
  /// Returns a widget representing the expanded view of a stack item
  Widget buildExpandedView(
    StackItemModel item,
    int index,
    T viewModel,
    double deviceHeight,
    double deviceWidth,
  );

  /// Constructs the collapsed state of a stack item
  ///
  /// [item] The current stack item to be rendered in collapsed state
  /// [index] The position of the item in the stack
  /// [viewModel] The view model controlling the view's state
  /// Returns a widget representing the collapsed view of a stack item
  Widget buildCollapsedView(
    StackItemModel item,
    int index,
    T viewModel,
  );

  /// Manages the initialization logic for the view
  ///
  /// [context] The build context for initialization
  void initializeView(BuildContext context);

  /// Handles navigation when back/pop action is triggered
  ///
  /// [context] The build context for navigation handling
  void handleBackNavigation(BuildContext context,T viewModel);

  /// Provides error handling and error state widgets
  ///
  /// [context] The build context
  /// [error] The error message or object
  /// Returns a widget to display when an error occurs
  Widget buildErrorView(BuildContext context, dynamic error);

  /// Provides loading indicator or state
  ///
  /// [context] The build context
  /// Returns a widget to display during loading
  Widget buildLoadingView(BuildContext context);

  /// Determines if the view can be popped or navigated back
  ///
  /// [context] The build context
  /// Returns a boolean indicating if navigation back is allowed
  bool canNavigateBack(BuildContext context, T viewModel);

  /// Provides additional configuration or setup for the view
  ///
  /// Allows for dynamic configuration of view behavior
  void configureView();
}

/// An extension to provide default implementations for some abstract methods
extension StackAbstractViewExtension<T extends StackAbstractViewmodel>
    on StackAbstractView<T> {
  /// Default implementation for error view
  Widget defaultErrorView(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'An error occurred',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Default implementation for loading view
  Widget defaultLoadingView(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Default implementation for back navigation
  bool defaultCanNavigateBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}
