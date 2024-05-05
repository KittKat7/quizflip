
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';


Future<void> writeToFileDesktop(String outputFile, String content) async {
  final file = File(outputFile);
  await file.writeAsString(content);
}//e writeToFileDesktop()

Future<String> readFromFileDesktop(String inputFile) async {
  final file = File(inputFile);
  return await file.readAsString();
}//e readFromFileDesktop()

Future<String?> pickOutFileDesktop() async {
  String downloadDir = "${(await getDownloadsDirectory())?.path}/";

  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: 'output-file.pdf',
    initialDirectory: downloadDir
  );
  return outputFile;
}//e pickOutFileDesktop()

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

Future<void> pickWriteFileDesktop(String content) async {
  // Get the outputFile as the path for the file to be written.
  String? outputFile = await pickOutFileDesktop();
  // If the user cancels, outputFile will be null, in this case: return.
  if (outputFile == null) return;
  // Write the contents to the file outputFile.
  await writeToFileDesktop(outputFile, content);
}//e pickWriteFileDecktop()

Future<String?> pickReadFileDesktop() async {
  String? inputFile = await pickInFileDesktop();

  if (inputFile == null) return null;

  return await readFromFileDesktop(inputFile);
}