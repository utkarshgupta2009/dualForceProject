// loading_steps.dart
import 'package:flutter/material.dart';

enum StepStatus { pending, loading, complete }

class LoadingStep {
  final String label;
  StepStatus status;

  LoadingStep({
    required this.label,
    this.status = StepStatus.pending,
  });
}

class LoadingStepsIndicator extends StatelessWidget {
  final List<LoadingStep> steps;

  const LoadingStepsIndicator({
    Key? key,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          
          return Column(
            children: [
              Row(
                children: [
                  _buildStepIndicator(step.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getTextColor(step.status),
                      ),
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Container(
                    width: 2,
                    height: 24,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepIndicator(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          ),
        );
      case StepStatus.loading:
        return SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case StepStatus.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Container(
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
    }
  }

  Color _getTextColor(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return Colors.green;
      case StepStatus.loading:
        return Colors.blue;
      case StepStatus.pending:
        return Colors.grey;
    }
  }
}