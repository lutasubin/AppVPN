import 'dart:math';

final List<String> uploadSpeeds = [
  '10mb/s',
  '20mb/s',
  '30mb/s',
  '40mb/s',
  '50mb/s',
  '60mb/s',
  '70mb/s',
  '80mb/s',
  '90mb/s',
  '100mb/s',
  '150mb/s',
  '160mb/s',
  '170mb/s',
  '180mb/s',
  '200mb/s',
  '300mb/s',
  '320mb/s',
  '350mb/s',
  '400mb/s',
  '450mb/s',
  '500mb/s',
  '550mb/s',
  '600mb/s',
  '700mb/s',
];

final List<String> downloadSpeeds = [
  '10mb/s',
  '20mb/s',
  '30mb/s',
  '40mb/s',
  '50mb/s',
  '60mb/s',
  '70mb/s',
  '80mb/s',
  '90mb/s',
  '100mb/s',
  '150mb/s',
  '160mb/s',
  '200mb/s',
  '250mb/s',
  '260mb/s',
  '300mb/s',
  '400mb/s',
  '500mb/s',
  '550mb/s',
  '580mb/s',
  '600mb/s',
  '700mb/s',
];

String getRandomUploadSpeed() {
  final random = Random();
  return uploadSpeeds[random.nextInt(uploadSpeeds.length)];
}

String getRandomDownloadSpeed() {
  final random = Random();
  return downloadSpeeds[random.nextInt(downloadSpeeds.length)];
}
