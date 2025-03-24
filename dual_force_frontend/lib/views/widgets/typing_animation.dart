import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;
  
  const TypingIndicator({
    Key? key,
    required this.isTyping,
  }) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _indicatorSpaceAnimation;
  
  late List<AnimationController> _dotControllers;
  final List<Animation<double>> _dotAnimations = [];

  @override
  void initState() {
    super.initState();
    
    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));
    
    _dotControllers = List<AnimationController>.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    
    for (var i = 0; i < 3; i++) {
      _dotAnimations.add(
        CurvedAnimation(
          parent: _dotControllers[i],
          curve: Curves.easeInOut,
        ).drive(Tween<double>(begin: 0.0, end: 1.0)),
      );
    }
    
    if (widget.isTyping) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isTyping != oldWidget.isTyping) {
      if (widget.isTyping) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController.forward();
    
    // Start the dots animation after a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animateDots();
      }
    });
  }

  void _hideIndicator() {
    _appearanceController.reverse();
    for (var controller in _dotControllers) {
      controller.stop();
    }
  }

  void _animateDots() {
    // Use staggered animation for the dots
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted && widget.isTyping) {
          _dotControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not typing, return an empty container with zero height to avoid taking space
    if (!widget.isTyping) {
      return const SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _indicatorSpaceAnimation,
      child: SizeTransition(
        sizeFactor: _indicatorSpaceAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _dotAnimations[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -4.0 * _dotAnimations[i].value),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}