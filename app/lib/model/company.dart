import 'package:rate_it/model/review.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../firestore/database.dart';

Future<List<Company>> searchCompanies(String query,{int limit=10, int page=1}) async {
  String apiKey = '80ab3270aee92b0b9b864fa3ae812ee9';
  String url = 'https://api.itjobs.pt/company/search.json?q=$query&api_key=$apiKey';
  url += '&limit=$limit';
  url += '&page=$page';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> results = jsonDecode(response.body)['results'];
    List<Company> companies = [];
    for (var result in results) {
      Company company = Company.fromJson(result);
      company.setAverageRating();
      companies.add(company);
    }
    return companies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Companies');
  }
}

Future<List<Company>> fetchCompanies({int limit=10, int page=1}) async {
  String apiKey = '80ab3270aee92b0b9b864fa3ae812ee9';
  String url = 'https://api.itjobs.pt/company/search.json?api_key=$apiKey';
  url += '&limit=$limit';
  url += '&page=$page';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> results = jsonDecode(response.body)['results'];
    List<Company> companies = [];
    for (var result in results) {
      Company company = Company.fromJson(result);
      company.setAverageRating();
      companies.add(company);
    }
    return companies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Companies');
  }
}

Future<Company> getCompany(String slug) async {
  String apiKey = '80ab3270aee92b0b9b864fa3ae812ee9';
  String url = 'https://api.itjobs.pt/company/get.json?api_key=$apiKey';
  url += '&slug=$slug';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map<String, dynamic> result = jsonDecode(response.body);
    Company company = Company.fromJson(result);
    company.setAverageRating();
    return company;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Companies');
  }
}


class Company{
  final int entityOrigin; //0 if itjobs; 1 if RateIT
  final int id;
  final String name;
  String logo;
  String description;
  String address;
  String phone;
  String fax;
  String email;
  String url;
  String url_twitter;
  String url_facebook;
  String url_linkedin;
  String slug;
  double averageRating;
  Future<List<Review>> reviews;

  Company({
    required this.id,
    required this.entityOrigin,
    required this.name,
    this.logo = "",
    this.description = "",
    this.address = "",
    this.phone = "",
    this.fax = "",
    this.email = "",
    this.url = "",
    this.url_twitter = "",
    this.url_facebook = "",
    this.url_linkedin = "",
    this.averageRating = 0,
    this.slug = "",
    required this.reviews,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      entityOrigin: 0,
      id: json['id'],
      name: json['name']??"",
      logo: json['logo']??"",
      description: json['description']??"",
      address: json['address']??"",
      phone: json['phone']?.toString()??"",
      fax: json['fax']?.toString()??"",
      email: json['email']??"",
      url: json['url']??"",
      url_twitter: json['url_twitter']??"",
      url_facebook: json['url_facebook']??"",
      url_linkedin: json['url_linkedin']??"",
      slug: json['slug']??"",
      reviews: Database.fetchReviews(json['id'],0,0),
    );
  }


  void setAverageRating() async{
    List<Review> rendReviews = await reviews;
    int sum = 0;
    for (Review r in rendReviews){
      sum += r.rating;
    }
    if (sum != 0) {
      averageRating = sum / rendReviews.length;
    } else {
      averageRating = 0;
    }
  }
}


