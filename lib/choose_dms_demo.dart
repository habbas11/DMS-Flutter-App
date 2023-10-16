import 'package:dms_demo/run_model_by_camera_demo.dart';
import 'package:dms_demo/run_model_by_image_demo.dart';
import 'package:flutter/material.dart';

class ChooseDmsDemo extends StatelessWidget {
  const ChooseDmsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RunModelByCameraDemo()),
            )
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Run Model with Camera",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        TextButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RunModelByImageDemo()),
            )
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Run Model with Image",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
