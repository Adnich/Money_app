import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show SocketException; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoanDecisionService {
  final http.Client _client;
  final bool preferRemoteRandom; 

  LoanDecisionService({
    http.Client? client,
    this.preferRemoteRandom = true,
  }) : _client = client ?? http.Client();

  Future<int> _fetchRandomNumberRemote() async {
    final uri = Uri.parse(
      'https://www.randomnumberapi.com/api/v1.0/random?min=0&max=100&count=1',
    );

    try {
      final resp = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! num) {
        throw FormatException('Unexpected JSON: ${resp.body}');
      }

      return (decoded.first as num).toInt();
    } on TimeoutException {
      throw Exception('Timeout contacting randomnumberapi.com');
    } on SocketException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Bad JSON from API: $e');
    }
  }

  int _randomLocal() {
    return Random.secure().nextInt(101);
  }


  Future<int> fetchRandomNumber() async {
    if (!preferRemoteRandom) return _randomLocal();

    if (kIsWeb) {
      try {
        return await _fetchRandomNumberRemote();
      } catch (e) {
        debugPrint('Remote RNG failed on Web: $e — using local RNG.');
        return _randomLocal();
      }
    }

    try {
      return await _fetchRandomNumberRemote();
    } catch (e) {
      debugPrint('Remote RNG failed: $e — using local RNG.');
      return _randomLocal();
    }
  }

  Future<String> decideLoan({
    required double accountBalance,
    required double monthlySalary,
    required double monthlyExpenses,
    required double loanAmount,
    required int loanTerm,
  }) async {
    final randomNumber = await fetchRandomNumber();

    final loanCost = loanAmount / loanTerm;
    final thirdSalary = monthlySalary / 3;

    if (randomNumber <= 50) return "DECLINED_RULE_1";
    if (accountBalance <= 1000) return "DECLINED_RULE_2";
    if (monthlySalary <= 1000) return "DECLINED_RULE_3";
    if (monthlyExpenses >= thirdSalary) return "DECLINED_RULE_4";
    if (loanCost >= thirdSalary) return "DECLINED_RULE_5";

    return "APPROVED";
  }
}
