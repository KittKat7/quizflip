import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> readFromFileDesktop(String inputFile) async {
  final file = File(inputFile);
  return await file.readAsString();
}//e readFromFileDesktop()

Future<String?> pickInFileDesktop() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? inputFile = (await FilePicker.platform.pickFiles(
    allowMultiple: false,
    initialDirectory: downloadDir,
    type: FileType.custom,
    allowedExtensions: ['json', 'flshpws-json']
  ))?.paths[0];
  return inputFile;
}//e pickInFileDesktop()

Future<String?> pickReadFileMobile() async {
  String? inputFile = await pickInFileDesktop();

  if (inputFile == null) return null;

  return await readFromFileDesktop(inputFile);
}

Future<void> pickAndWriteToFileMobile(String name, String content) async {
  try {
    // Allow the user to pick a directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) return;
    // Specify the file path within the selected directory
    String filePath = '$selectedDirectory/$name';

    // Open the file in write mode
    File file = File(filePath);
    IOSink sink = file.openWrite(mode: FileMode.write);

    // Write content to the file
    sink.write(content);

    // Close the file
    await sink.close();

    print('File written successfully at: $filePath');

  } catch (e) {
    // Handle exceptions if any
    print('Error picking and writing file: $e');
  }
}