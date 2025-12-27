import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/views/widgets/description_text_field.dart';
import 'package:scribe/views/widgets/primary_button.dart';

class RequestFeatureScreen extends StatefulWidget {
  const RequestFeatureScreen({super.key});

  @override
  State<RequestFeatureScreen> createState() => _RequestFeatureScreenState();
}

class _RequestFeatureScreenState extends State<RequestFeatureScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request new feature"),
        backgroundColor: AppColors.lightBlackColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            spacing: 24,
            children: [
              DescriptionTextField(
                title: "Title",
                hintText: "Dark mode",
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title cannot be empty";
                  }
                  return null;
                },
                maxLine: 1,
              ),
              DescriptionTextField(
                title: "Description",
                hintText: "More about the feature",
                controller: descriptionController,
                height: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title cannot be empty";
                  }
                  return null;
                },
                maxLine: null,
              ),
              Spacer(),
              PrimaryButton(
                text: "Send Request",
                backgroundColor: AppColors.blackColor,
                textColor: AppColors.whiteColor,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}