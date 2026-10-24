// import 'dart:async';
// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:finance_pulse/core/network/api_service.dart';
// import 'package:finance_pulse/core/network/utils/logging_interceptor.dart';

// import 'api_service_test.mocks.dart';

// @GenerateMocks([Dio, HttpClientAdapter, LoggingInterceptor])
// void main() {
//   late ApiService apiService;
//   late MockHttpClientAdapter mockHttpClientAdapter;
//   late MockDio mockDio;

//   setUp(() {
//     mockHttpClientAdapter = MockHttpClientAdapter();
//     mockDio = MockDio();
//     mockDio.httpClientAdapter = mockHttpClientAdapter;

//     apiService = ApiService(mockDio);
//   });

//   group("get", () {
//     setUp(() {
//       mockDio.interceptors.add(MockLoggingInterceptor());
//       // final fakeInterceptors = Interceptors();
//       // when(mockDio.interceptorsa).thenReturn(MockLoggingInterceptor());
//     });
//     test(
//       "should return response from any url",
//       () async {
//         //arrange
//         // String payload = jsonEncode({"status": true});

//         final response =
//             Future.value(Response(requestOptions: RequestOptions()));
//         when(mockDio.get(any)).thenAnswer((_) => response);

//         //act
//         var result = apiService.get("any");

//         //asserts
//         expect(result, response);
//       },
//     );
//   });
// }
