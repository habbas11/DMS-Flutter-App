# **Driver Monitoring System Flutter App**

**Overview**

This is a Flutter app designed to monitor a driver's behavior using an advanced YOLOv8 model for real-time object detection. The app can detect different objects in the driver's surroundings, such as:

- Open Eyes
- Closed Eyes
- Cigarettes
- Phones
- Seatbelts

The primary goal of this app is to improve driver safety by alerting them or a monitoring system when potentially dangerous behaviors or objects are detected. This README will guide you through setting up and using this driver monitoring system.

**Prerequisites**

Before using this app, make sure you have the following prerequisites:

- Flutter and Dart installed on your computer. You can follow the official Flutter installation guide: [Flutter Installation](https://flutter.dev/docs/get-started/install).
- A compatible mobile device or an Android/iOS emulator.

**Usage**

1. Open the app on your device or emulator.
2. The app will use your device's camera to begin real-time object detection.
3. The YOLOv8 model will identify objects within the driver's field of view.
4. Detected objects will be categorized as "Open Eye," "Closed Eye," "Cigarette," "Phone," or "Seatbelt."
5. If an unsafe behavior or object is detected, the app may issue warnings or alerts to the driver.
6. You can customize the way alerts work and set your own safety thresholds by adjusting the app's code.
7. To stop the monitoring, simply close the app or navigate away from the detection screen.

**License**

This app is released under the MIT License. See [LICENSE](https://chat.openai.com/c/LICENSE) for details.

Please note that this application is designed for educational and demonstration purposes. It may need further customization and integration with specific hardware and systems for use in real-world driver monitoring scenarios. Always prioritize safety and legal compliance when using such systems in actual vehicles.