import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class CustomChoiceChip extends StatefulWidget {
  const CustomChoiceChip({super.key});

  @override
  State<CustomChoiceChip> createState() => _CustomChoiceChipState();
}

class _CustomChoiceChipState extends State<CustomChoiceChip> {
  int tag = 0;

  String selectedTag = "All Time";

  List<String> options = [
    "All Time",
    "Today",
    "This Week",
    "This Month",
    "Favourite",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 6.0,
        children: List<Widget>.generate(options.length, (int index) {
          return ChoiceChip(
            label: Text(options[index]),
            selected: tag == index,
            onSelected: (bool selected) {
              debugPrint(options[index]);
              setState(() {
                tag = selected ? index : tag;
                selectedTag = options[index];
              });
            },
            selectedColor: AppColors.blackColor,
            backgroundColor: AppColors.lightBlackColor,
            labelStyle: TextStyle(
              color: tag == index
                  ? AppColors.whiteColor
                  : AppColors.lightTextColor,
            ),
            showCheckmark: false,
          );
        }).toList(),
      ),
    );
  }
}
