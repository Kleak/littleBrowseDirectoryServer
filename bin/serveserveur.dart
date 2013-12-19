import 'dart:io' as IO;

String address = "127.0.0.1";
int port = 8888;

void main() {
  IO.HttpServer.bind(address, port).then((IO.HttpServer hs) {
    hs.listen((IO.HttpRequest req) {
      String path = "./web${req.uri.path}";

      if (IO.FileSystemEntity.isDirectorySync(path)) {
        IO.Directory dir = new IO.Directory(path);
        List listdir = dir.listSync(recursive: false, followLinks: false);

        req.response.headers.set(IO.HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
        StringBuffer sb = new StringBuffer();

        listdir.forEach((dir) {
          Uri uri = new Uri.file(dir.path);
          if (!IO.FileSystemEntity.isLinkSync(dir.path)) {
            sb.write("<a");
            StringBuffer fakepath = new StringBuffer();
            for (int i = 2; i < uri.pathSegments.length; i++) {
              fakepath.write("/");
              fakepath.write(uri.pathSegments[i]);
            }
            sb.write(' href="${fakepath.toString()}"');
            if (IO.FileSystemEntity.isFileSync(dir.path)) {
              sb.write('download="${uri.pathSegments[uri.pathSegments.length - 1]}"');
            }
            sb.write(">");
            sb.write("${uri.pathSegments[uri.pathSegments.length - 1]}");
            sb.write("</a></br>");
          }
        });
        req.response.write(sb.toString());
        req.response.close();
      }

      if (IO.FileSystemEntity.isFileSync(path)) {
        IO.File file = new IO.File(path);
        file.openRead().pipe(req.response).catchError((e) { print('error pipe!'); });
      }

    });
  }, onError: (e) {
    print(e);
  });
}
