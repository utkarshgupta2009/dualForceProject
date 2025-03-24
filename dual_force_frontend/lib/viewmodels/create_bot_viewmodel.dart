import 'dart:io';

import 'package:dual_force/data/response/api_response.dart';
import 'package:dual_force/models/expert_system.dart';
import 'package:dual_force/repository/expert_system_repository.dart';
import 'package:dual_force/utils/toast_message.dart';
import 'package:dual_force/views/widgets/loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/abstarct_layer/stack_abstarct_viewmodel.dart';
import 'package:dual_force/abstarct_layer/stack_item_model.dart';

class CreateBotViewmodel extends ChangeNotifier
    implements StackAbstractViewmodel {
  // final StackFrameworkRepository _apiService = StackFrameworkRepository();
  List<StackItemModel> _stackItems = [];
  List<StackItemModel> _currentStackItems = [];
  bool _isLoading = false;
  String? _error;
  List<LoadingStep> loadingSteps = [
    LoadingStep(label: 'Processing Document'),
    LoadingStep(label: 'Creating Expert System'),
    LoadingStep(label: 'Finalizing Setup'),
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ExpertSystemRepository _expertSystemRepository =
      ExpertSystemRepository();

  File? selectedFile;
  String? fileName;
  bool isFileSelected = false;
  String? uploadedFileUrl;
  ExpertSystem? newlyCreatedExpertSystem;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null) {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
        isFileSelected = true;

        notifyListeners();
      }
    } catch (e) {
      _error = "Error picking file: ${e.toString()}";
      notifyListeners();
    }
  }

  List<StackItemModel> sampleStackItems = [
    StackItemModel(
      openState: OpenState(
        body: OpenStateBody(
          title: "Choose Document",
          subtitle:
              "It can be any book, any legal document, any documentation of software.\npdf cccepted",
        ),
      ),
      closedState: ClosedState(
        title: "Document selected",
        subtitle: "Class 12 NCERT",
      ),
      ctaText: "Proceed to set details",
    ),
    StackItemModel(
      openState: OpenState(
        body: OpenStateBody(
          title: "Give name and Description ",
          subtitle: "Give a name so you can easily remember",
        ),
      ),
      closedState: ClosedState(
        title: "Name set",
        subtitle: "Phsyics Bot",
      ),
      ctaText: "Proceed to overview",
    ),
    StackItemModel(
      openState: OpenState(
        body: OpenStateBody(
          title: "Overview of bot",
          subtitle: "Review the bot",
        ),
      ),
      closedState: ClosedState(
        title: "Closed Title 3",
        subtitle: "Closed Description 3",
      ),
      ctaText: "Create Bot",
    ),
  ];

  @override
  List<StackItemModel> get stackItems => _stackItems;
  @override
  List<StackItemModel> get currentStackItems => _currentStackItems;

  @override
  bool get isLoading => _isLoading;
  @override
  String? get error => _error;

  @override
  Future<void> fetchStackItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stackItems = sampleStackItems;
      if (_currentStackItems.isNotEmpty) {
        _currentStackItems.clear();
      }

      // Ensuring between 2-4 items only
      if (_stackItems.length < 2) {
        _error = 'Minimum 2 items required';
      } else if (_stackItems.length > 4) {
        _stackItems = _stackItems.sublist(0, 4);
      }
      _currentStackItems.add(_stackItems.first);
      _currentStackItems.first.isExpanded = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void toggleItemExpansion(int index) {
    for (int i = 0; i < _currentStackItems.length; i++) {
      if (index == _currentStackItems.length - 1) {
        return;
      } else if (i == index) {
        _currentStackItems[i].isExpanded = !_currentStackItems[i].isExpanded;
        if (_currentStackItems.length > i) {
          _currentStackItems.removeRange(i + 1, _currentStackItems.length);
        }
      } else if (i > index) {
        _currentStackItems.removeAt(i);
      } else if (i < index) {
        _currentStackItems[i].isExpanded = false;
      }
    }
    notifyListeners();
  }

  @override
  void removeCurrentExpandedItem(int expandedIndex) {
    // Find the index of the expanded item

    // If an expanded item exists
    if (expandedIndex > 0) {
      // Remove the current expanded item
      currentStackItems.removeAt(expandedIndex);

      // If there are still items in the list after removal
      if (currentStackItems.isNotEmpty) {
        // Determine the index of the previous item to expand
        // If the removed item was the last one, expand the new last item
        // Otherwise, expand the item at the same index (which is now the next item)
        final newExpandIndex = expandedIndex > 0 ? expandedIndex - 1 : 0;

        // Collapse all items first
        for (var item in currentStackItems) {
          item.isExpanded = false;
        }

        // Expand the previous (or last remaining) item
        currentStackItems[newExpandIndex].isExpanded = true;
      }

      notifyListeners();
    }
  }

  @override
  Future<void> getCtaOnPressed(
      int currentIndex, CreateBotViewmodel viewmodel, String userId) async {
    //currently I am just updating the ui and no functionality implemented
    //we can use switch case based on currentIndex to implement proper functionality of each cta
    //I have created mock onPressed Functions
    //here is code for cta functionality
    switch (currentIndex) {
      case 0:
        onPressedFirstCta(currentIndex, viewmodel);
      case 1:
        onPressedSecondCta(currentIndex);
      case 2:
        await onPressedThirdCta(currentIndex, userId);
      default:
        throw Error();
    }
  }

  void _addItemsToCurrentStack(int currentIndex) {
    if (currentIndex < stackItems.length - 1) {
      _currentStackItems.add(stackItems[currentIndex + 1]);
      _currentStackItems[currentIndex + 1].isExpanded = true;
      _currentStackItems[currentIndex].isExpanded = false;
    }
    notifyListeners();
  }

  void onPressedFirstCta(int currentIndex, CreateBotViewmodel viewmodel) {
    if (selectedFile != null) {
      _addItemsToCurrentStack(currentIndex);
      //
    }
  }

  void onPressedSecondCta(int currentIndex) async {
    _addItemsToCurrentStack(currentIndex);
    // await DocumentService().getQueryEmbeddings("what is newgen");
    //we can add other logic in future to handle the cta on pressed
  }

  void setIsloading(bool val) {
    _isLoading = true;
    notifyListeners();
  }

  Future<void> onPressedThirdCta(int currentIndex, String userId) async {
    try {
      if (selectedFile == null) {
        _error = "No file selected";
        notifyListeners();
        return;
      }

      if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
        ToastUtils.showErrorToast("Name and description are required");
        notifyListeners();
        return;
      }

      setIsloading(true);

      _addItemsToCurrentStack(currentIndex);
      final _apiResponse = await _expertSystemRepository.createExpertSystem(
          selectedFile!,
          userId,
          nameController.text,
          descriptionController.text);
      if (_apiResponse.status == Status.ERROR) {
        ToastUtils.showErrorToast(_apiResponse.message);
        return;
      }
      newlyCreatedExpertSystem = ExpertSystem.fromMap(_apiResponse.data);

      setIsloading(false);
      notifyListeners();
    } catch (e) {
      setIsloading(false);
      ToastUtils.showErrorToast(
          "Error creating expert system: ${e.toString()}");
      notifyListeners();
    }
  }
}
