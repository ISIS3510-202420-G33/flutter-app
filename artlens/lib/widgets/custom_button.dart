import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.label,
    this.backgroundColor = Colors.black, // Default background is black
    this.textColor = Colors.white, // Default text color is white
    required this.onPressed,
    this.width = double.infinity, // Default width to infinity
    this.height = 48.0, // Default height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor, // Background color parameter
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onPressed, // Button action
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor, // Text color parameter
              ),
            ),
          ),
        ),
      ),
    );
  }
}
