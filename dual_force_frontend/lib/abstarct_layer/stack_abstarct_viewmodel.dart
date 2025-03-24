import 'package:dual_force/abstarct_layer/stack_item_model.dart';
import 'package:dual_force/viewmodels/create_bot_viewmodel.dart';

abstract class StackAbstractViewmodel {
  // Core data management
  List<StackItemModel> get stackItems;
  List<StackItemModel> get currentStackItems;

  // Loading and error states
  bool get isLoading;
  String? get error;

  // Core actions
  Future<void> fetchStackItems();
  void toggleItemExpansion(int index);
  void removeCurrentExpandedItem(int expandedIndex);
  void getCtaOnPressed(int currentIndex,CreateBotViewmodel viewmodel,String userId);
}
