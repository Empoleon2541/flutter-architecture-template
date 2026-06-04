import 'dart:io';

import 'package:mobile_app/common/extension/string_extension.dart';
import 'package:path/path.dart' as path;

void main() async {
  // Output file path using platform-agnostic path joining
  final outputFile = File(path.join('lib', 'gen', 'assets.gen.dart'));

  // Create directories if they don't exist
  await outputFile.parent.create(recursive: true);

  // Start writing the Dart file
  final buffer = StringBuffer()
    ..writeln('''
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  App Asset Generator
/// *****************************************************

library;
''');

  // Process the assets directory for different types
  await processDirectory(Directory('assets'), buffer);

  // Write to file
  await outputFile.writeAsString(buffer.toString());

  // Format the file using dart format
  await Process.run('dart', ['format', outputFile.path]);
}

/// Processes a directory and its subdirectories to generate asset constants
///
/// [dir] The directory to process
/// [buffer] The string buffer to write to
Future<void> processDirectory(Directory dir, StringBuffer buffer) async {
  if (!dir.existsSync()) return;

  // Maps to store assets by type
  final assetsByType = <String, List<AssetFile>>{
    'Icons': [], // SVG files
    'Images': [], // PNG, JPG, etc.
  };

  // Process all files recursively
  await _processFiles(dir, '', assetsByType);

  // Generate classes for each type
  for (final entry in assetsByType.entries) {
    if (entry.value.isEmpty) continue;

    buffer.writeln('\nclass Asset${entry.key} {');

    // Sort assets by path for consistent ordering
    entry.value.sort((a, b) => a.path.compareTo(b.path));

    for (final asset in entry.value) {
      buffer.writeln(
        "  static const String ${asset.variableName} = '${asset.path}';",
      );
    }

    buffer.writeln('}');
  }
}

Future<void> _processFiles(
  Directory dir,
  String currentPath,
  Map<String, List<AssetFile>> assetsByType,
) async {
  final entities = await dir.list().toList();

  // Process files
  final files = entities.whereType<File>();
  for (final file in files) {
    final extension = path.extension(file.path).toLowerCase();
    final relativePath = path
        .relative(file.path, from: 'assets')
        .replaceAll(r'\', '/');

    final assetPath = 'assets/$relativePath';
    final fileName = path.basenameWithoutExtension(file.path);
    final dirName = path.basename(path.dirname(file.path));

    // Create camelCase variable name combining directory and file names
    final variableName = currentPath.isEmpty
        ? fileName.toCamelCase()
        : '${dirName}_$fileName'.toCamelCase();

    if (extension == '.svg') {
      assetsByType['Icons']!.add(AssetFile(assetPath, variableName));
    } else if (['.png', '.jpg', '.jpeg', '.gif'].contains(extension)) {
      assetsByType['Images']!.add(AssetFile(assetPath, variableName));
    }
  }

  // Process subdirectories
  final directories = entities.whereType<Directory>();
  for (final subdir in directories) {
    final subdirName = path.basename(subdir.path);
    final newPath = currentPath.isEmpty
        ? subdirName
        : '${currentPath}_$subdirName';
    await _processFiles(subdir, newPath, assetsByType);
  }
}

/// Helper class to store asset information
class AssetFile {
  AssetFile(this.path, this.variableName);
  final String path;
  final String variableName;
}
