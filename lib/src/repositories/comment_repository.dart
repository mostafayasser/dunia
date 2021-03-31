import 'dart:async';
import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

import '../helpers/helper.dart';

Future<Stream<CommentData>> getComments(int videoId, int page) async {
  Uri uri = Helper.getUri('fetch-video-comments');
  uri = uri.replace(queryParameters: {
    "page": page.toString(),
    "video_id": videoId.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    http.Request request = new http.Request("post", uri);
    request.headers.clear();
    request.headers.addAll(headers);

    final streamedRest = await request.send();
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      print(data);
      return CommentData.fromJson(data);
    });
  } catch (e) {
    print("video Error");
    print(e.toString());
    return new Stream.value(new CommentData.fromJson({}));
  }
}

Future<int> addComment(CommentData obj) async {
  Uri uri = Helper.getUri('add-comment');
  uri = uri.replace(queryParameters: {
    "user_id": obj.userId.toString(),
    "app_token": obj.token,
    "video_id": obj.videoId.toString(),
    "comment": obj.comment.toString()
  });

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    return json.decode(response.body)['comment_id'];
  } catch (e) {
    print(e.toString());
    return 0;
  }
}
