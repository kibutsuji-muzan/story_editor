import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List searchedList = [];
List topSongsList = [];
String kUrl = "",
    checker = "",
    image = "",
    title = "",
    album = "",
    artist = "",
    lyrics = "",
    has_320 = "",
    rawkUrl = "";
String key = "38346591";
String decrypt = "";

Future<List> fetchSongsList(searchQuery) async {
  var searchUrl = Uri.parse(
      "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&query=$searchQuery&__call=autocomplete.get");
  var res = await http.get(searchUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  searchedList = getMain["songs"]["data"];
  for (int i = 0; i < searchedList.length; i++) {
    searchedList[i]['title'] = searchedList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");

    searchedList[i]['more_info']['singers'] = searchedList[i]['more_info']
            ['singers']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
  }
  return searchedList;
}

Future<List> topSongs() async {
  String topSongsUrl =
      "https://www.jiosaavn.com/api.php?__call=webapi.get&token=8MT-LQlP35c_&type=playlist&p=1&n=20&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON = await http
      .get(Uri.parse(topSongsUrl), headers: {"Accept": "application/json"});
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}
