import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pytorch_lite/native_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choose_dms_demo.dart';
import 'classes/dms_model_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PytorchFfi.init();
  runApp(const ModelConfig());
}

class ModelConfig extends StatefulWidget {
  const ModelConfig({Key? key}) : super(key: key);

  @override
  State<ModelConfig> createState() => _ModelConfigState();
}

class _ModelConfigState extends State<ModelConfig> {
  bool modelDownloading = false;
  bool askForUpdate = true;
  late Future<DmsModelInfo> dmsModelInfoFuture;
  late DmsModelInfo dmsModelInfo;
  late Future<bool> isModelAvailable;
  late Future<bool> isUpdateAvailable;
  String downloadProgressString = '0%';
  double downloadProgressDouble = 0.0;

  @override
  initState() {
    super.initState();
    dmsModelInfoFuture = _initModelState();
    requestPermissions();
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.storage] != PermissionStatus.granted) {
      requestPermissions();
    }
  }

  Future<DmsModelInfo> _initModelState() async {
    try {
      const repoUrl =
          "https://raw.githubusercontent.com/habbas11/test_json/main/DMS_Version.json";

      final dio = Dio();
      Response response = await dio.get(
        repoUrl,
        options: Options(
          headers: {
            'Authorization': 'token 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',
            'Accept': 'application/vnd.github.v4+raw',
            'Accept-Encoding': 'identity',
          },
        ),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.data);
        dmsModelInfo = DmsModelInfo.fromJson(jsonData);
        return dmsModelInfo;
      } else {
        throw Exception('Failed to load data.');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> _isModelAvailable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? modelDownloaded = prefs.getBool('modelDownloaded');
    if (modelDownloaded != null && modelDownloaded) return true;
    return false;
  }

  Future<bool> _isUpdateAvailable() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final modelVersion = prefs.getInt('modelVersion');
      final lastVersion = dmsModelInfo.version;
      if (modelVersion != lastVersion) return true;
      return false;
    } catch (e) {
      throw Exception(e);
    }
  }

  void initFutures() {
    isModelAvailable = _isModelAvailable();
    isUpdateAvailable = _isUpdateAvailable();
  }

  Future<void> updateModel() async {
    final modelUrl = dmsModelInfo.modelLink;
    final modelFileName = dmsModelInfo.modelName;
    final labelsUrl = dmsModelInfo.labelsLink;
    const labelsFileName = 'dms_labels.txt';

    setState(() {
      modelDownloading = true;
    });

    Directory? downloadsDirectory = await getDownloadsDirectory();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    await dio.download(modelUrl, '${downloadsDirectory?.path}/$modelFileName',
        onReceiveProgress: (received, total) async {
      if (total != -1) {
        setState(() {
          downloadProgressString =
              "${((received / total) * 100).toStringAsFixed(0)}%";
          downloadProgressDouble = received / total;
        });
        if (received == total) {
          await prefs.setBool('modelDownloaded', true);
          await prefs.setInt('modelVersion', dmsModelInfo.version);
          await prefs.setString('modelName', dmsModelInfo.modelName);
          await prefs.setString(
              'modelPath', '${downloadsDirectory?.path}/$modelFileName');
        }
      }
    });

    await dio.download(
      labelsUrl,
      '${downloadsDirectory?.path}/$labelsFileName',
      options: Options(
        headers: {
          'Authorization': 'token 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',
          'Accept': 'application/vnd.github.v4+raw',
          'Accept-Encoding': 'identity',
        },
      ),
    );
    await prefs.setString(
        'labelsPath', '${downloadsDirectory?.path}/$labelsFileName');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
        secondaryHeaderColor: Colors.black,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DMS Demo'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: FutureBuilder(
              future: Future.wait([dmsModelInfoFuture]),
              builder: (context, AsyncSnapshot<List<DmsModelInfo>> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                initFutures();
                return FutureBuilder(
                  future: Future.wait(
                    [isModelAvailable, isUpdateAvailable],
                  ),
                  builder: (context, AsyncSnapshot<List<bool>> snapshot) {
                    final isModelAvailable = snapshot.data?[0];
                    final isUpdateAvailable = snapshot.data?[1];
                    if (isModelAvailable != null && !isModelAvailable) {
                      return AlertDialog(
                        title: modelDownloading
                            ? const Text('Downloading Required Model...')
                            : const Text('Model Download is Required...'),
                        content: modelDownloading
                            ? CircularPercentIndicator(
                                radius: 40.0,
                                lineWidth: 5.0,
                                percent: downloadProgressDouble,
                                center: Text(downloadProgressString),
                                progressColor: Colors.green,
                              )
                            : const SizedBox(),
                        actions: modelDownloading
                            ? []
                            : [
                                ElevatedButton(
                                  onPressed: () async {
                                    await updateModel();
                                    setState(() {
                                      askForUpdate = false;
                                    });
                                  },
                                  child: const Text('Download'),
                                ),
                              ],
                      );
                    } else if (isUpdateAvailable != null &&
                        isUpdateAvailable &&
                        askForUpdate) {
                      return AlertDialog(
                        title: modelDownloading
                            ? const Text(
                                'Downloading...',
                              )
                            : const Text(
                                'A new updated model is available!',
                              ),
                        content: modelDownloading
                            ? CircularPercentIndicator(
                                radius: 40.0,
                                lineWidth: 5.0,
                                percent: downloadProgressDouble,
                                center: Text(downloadProgressString),
                                progressColor: Colors.green,
                              )
                            : const SizedBox(),
                        actions: modelDownloading
                            ? []
                            : [
                                ElevatedButton(
                                    onPressed: () => setState(() {
                                          askForUpdate = false;
                                        }),
                                    child: const Text('Skip')),
                                ElevatedButton(
                                    onPressed: () async {
                                      await updateModel();
                                      setState(() {
                                        askForUpdate = false;
                                      });
                                    },
                                    child: const Text('Download')),
                              ],
                      );
                    }
                    return const ChooseDmsDemo();
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
