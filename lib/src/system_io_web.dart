import 'dart:convert';
import 'package:universal_html/html.dart' as html;

void writeToFileWeb(String outputFile, String content) {
  final encodedContent = base64.encode(utf8.encode(content));
  final dataUri = 'data:text/plain;charset=utf-8;base64,$encodedContent';
  // ignore: unused_local_variable
  final anchorElement = html.AnchorElement(href: dataUri)
    ..setAttribute('download', outputFile)
    ..click();
}

Future<String> readFromFileWeb() async {
  // Create an input element
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  
  // Allow only text file types
  // uploadInput.accept = 'text/plain';
  
  // Trigger the file selection dialog
  uploadInput.click();
  
  // Wait for the user to select a file
  await uploadInput.onChange.first;
  
  // Access the selected file
  final file = uploadInput.files!.first;
  
  // Create a FileReader
  final reader = html.FileReader();
  
  // Read the file content as text
  reader.readAsText(file);
  
  // Wait for the file to be read
  await reader.onLoad.first;
  
  // Get the text content as a String
  final text = reader.result as String;
  
  return text;
}//e readFromFileWeb()
