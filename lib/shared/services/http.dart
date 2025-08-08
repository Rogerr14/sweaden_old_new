import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/login/pages/login_page.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class InterceptorHttp {
  Future<GeneralResponse> request(
    BuildContext? context,
    String method,
    String urlEndPoint,
    dynamic body, {
    bool showAlertError = true,
    bool showLoading = true,
    Map<String, dynamic>? queryParameters,
    List<http.MultipartFile>? multipartFiles,
    Map<String, String>? multipartFields,
    String requestType = "JSON",
    Function(int sentBytes, int totalBytes)? onProgressLoad,
  }) async {
    String url =
        "${AppConfig.appEnv.protocol}$urlEndPoint?${Uri(queryParameters: queryParameters).query}";

    Helper.logger.t('URL $method: $url');
    late final FunctionalProvider fp;

    body != null
        ? Helper.logger.log(Level.trace, 'body: ${json.encode(body)}')
        : null;
    queryParameters != null
        ? Helper.logger.log(
            Level.trace, 'queryParameters: ${json.encode(queryParameters)}')
        : null;
    // Function()? executeOnCloseModal;
    GeneralResponse generalResponse =
        GeneralResponse(data: null, message: "", error: true, existData: true);
    if (context != null) {
      fp = Provider.of<FunctionalProvider>(context, listen: false);
    }

    //?IN ERROR CASE
    String? messageButton;
    void Function()? onPress;
    try {
      http.Response _response;
      Uri uri = Uri.parse(url);
      if (showLoading) {
        if (context != null) {
          fp.showAlert(content: const AlertLoading());
        }
        await Future.delayed(const Duration(milliseconds: 600));
      }

      //? Envio de TOKEN
      AuthResponse? userData = await UserDataStorage().getUserData();

      String tokenSesion = "";
      if (userData != null) {
        tokenSesion = userData.token;
      }
      // print(tokenSesion);

      //tokenSesion = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3d3dy5zd2VhZGVuc2VndXJvcy5jb20vIiwiYXVkIjoiMTIyIiwianRpIjoiNWYwMDkyOGRkMTlmOTMzMjhmZDJmNjFlNzdmYTI5YTciLCJpYXQiOjE2Nzg4OTQ3NDQsIm5iZiI6MTY3ODg5NDc0NCwiZXhwIjoxNjgwMTkwNzQ0LCJkYXRhIjp7ImlkVXN1YXJpbyI6IjE1MiIsInRpcG9FbWlzaW9uIjoiQSIsImlkVXN1YXJpb0RCIjoxMTAsImlkVGlwb1VzdWFyaW8iOjN9fQ.MklOKJdscGGwfWn4J4_m4XRhGTnObHf8D9JAbDNUSsQ";
      //tokenSesion = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LnN3ZWFkZW5zZWd1cm9zLmNvbVwvIiwiYXVkIjoiMTIyIiwianRpIjoiNWYwMDkyOGRkMTlmOTMzMjhmZDJmNjFlNzdmYTI5YTciLCJpYXQiOjE2Nzg4OTQ3NDQsIm5iZiI6MTY3ODg5NDc0NCwiZXhwIjoxNjgwMTkwNzQ0LCJkYXRhIjp7ImlkVXN1YXJpbyI6IjEyMiIsInRpcG9FbWlzaW9uIjoiQSIsImlkVXN1YXJpb0RCIjoxMywiaWRUaXBvVXN1YXJpbyI6M319.-0tDUXcylQchA-mKuomx6m-LS1k1_xWcplpVu64nyvk";
      //?
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Map<String, String> _headers = {
        "Content-Type": "application/json",
        "Authorization":
            (requestType == 'JSON') ? 'Bearer $tokenSesion' : tokenSesion,
        "versionName":
            '${packageInfo.version} ${AppConfig.appEnv.environmentName}',
        // "versionName": "3.8.10",
        "versionCode": packageInfo.buildNumber,
        "idTransaccion": const Uuid().v4(),
        // "versionName": '1.8.10 DEV',
        // "versionCode": "1"
      };

      Helper.logger.w(_headers);

      int responseStatusCode = 0;
      String responseBody = "";

      switch (requestType) {
        case "JSON":
          switch (method) {
            case "POST":
              _response = await http.post(uri,
                  headers: _headers,
                  body: body != null
                      ? json.encode(body)
                      : null); //.timeout(const Duration(seconds: 10));
              //inspect(_response);
              break;
            case "GET":
              _response = await http.get(uri, headers: _headers);
              break;
            case "PUT":
              _response = await http.put(uri,
                  headers: _headers,
                  body: body != null ? json.encode(body) : null);
              break;
            case "PATCH":
              _response = await http.patch(uri,
                  headers: _headers,
                  body: body != null ? json.encode(body) : null);
              break;

            default:
              _response = await http.post(uri, body: jsonEncode(body));
              break;
          }
          responseStatusCode = _response.statusCode;
          responseBody = _response.body;

          // Helper.logger.w(_response.body);
          // if(responseBody.contains('<html>') == true){
          //   Helper.logger.log(Level.trace, responseBody);
          // }else{
          //   Helper.logger.log(Level.trace, json.decode(responseBody));
          // }
          //debugPrint("CONTENT: ${responseBody.contains('<!DOCTYPE html>')}");
          (responseBody.contains('<!DOCTYPE html>') ||
                      responseBody.contains('<script>')) ==
                  true
              ? Helper.logger
                  .e(
                      'error en intentar consultar a los servicios...') /*Helper.logger.log(Level.trace, responseBody)*/ : Helper
                  .logger
                  .log(Level.trace, json.decode(responseBody));
          // debugPrint("RESPONSE BODY: ${responseBody.contains('<html>') ? 'HTML' : 'responseBody'}");
          // debugPrint("STATUS_CODE: $responseStatusCode");

          //log(json.encode(responseBody));

          break;
        case "FORM":
          final httpClient = getHttpClient();
          final request = await httpClient.postUrl(Uri.parse(url));

          int byteCount = 0;
          var requestMultipart =
              // *BIEN
              http.MultipartRequest(method, Uri.parse(url));
          // print("requesMult");
          if (multipartFiles != null) {
            requestMultipart.files.addAll(multipartFiles);
          }
          if (multipartFields != null) {
            requestMultipart.fields.addAll(multipartFields);
          }

          _headers.forEach((key, value) {
            request.headers.set("Authorization", tokenSesion);
          });

          debugPrint("TOKEN CARGADO");

          var msStream = requestMultipart.finalize();

          var totalByteLength = requestMultipart.contentLength;

          request.contentLength = totalByteLength;

          request.headers.set(HttpHeaders.contentTypeHeader,
              requestMultipart.headers[HttpHeaders.contentTypeHeader]!);

          Stream<List<int>> streamUpload = msStream.transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) {
                sink.add(data);

                byteCount += data.length;

                if (onProgressLoad != null) {
                  onProgressLoad(byteCount, totalByteLength);
                }
              },
              handleError: (error, stack, sink) {
                generalResponse.error = true;
                throw error;
              },
              handleDone: (sink) {
                sink.close();
                // UPLOAD DONE;
              },
            ),
          );

          await request.addStream(streamUpload);

          final httpResponse = await request.close();
          var statusCode = httpResponse.statusCode;

          responseStatusCode = statusCode;
          if (statusCode ~/ 100 != 2) {
            throw Exception(
                'Error uploading file, Status code: ${httpResponse.statusCode}');
          } else {
            await for (var data in httpResponse.transform(utf8.decoder)) {
              responseBody = data;
            }
          }
          break;
      }

      switch (responseStatusCode) {
        case 200:
          var responseDecoded = json.decode(responseBody);
          generalResponse.data = responseDecoded["data"];
          generalResponse.existData = responseDecoded["hayData"] ?? true;
          var allowedVersion = true;
          if (responseDecoded['version'] != null) {
            allowedVersion = responseDecoded['version']['permitido'];
          }
          if (allowedVersion) {
            //debugPrint("---VERSION PERMITIDA---");
            // print(responseBody);
            // print(responseDecoded['existeError']);
            // print(responseDecoded['mensaje']);

            if (responseDecoded['existeError']) {
              // print("HAY ERROR");
              generalResponse.error = true;
            } else {
              generalResponse.error = false;
            }

            try {
              generalResponse.message = responseDecoded["mensaje"];
            } catch (e) {
              if (responseDecoded["mensaje"]["user"] ==
                  'El token enviado no es valido') {
                generalResponse.message = 'Su sesión ha caducado';
                messageButton = 'volver a ingresar';
                onPress = () async {
                  fp.dismissAlert();
                  await UserDataStorage().removeUserData();
                  if (context != null) {
                    Navigator.pushReplacement(
                        context,
                        Helper.navigationFadeIn(
                            context, const LoginPage(), 800));
                  }
                };
              } else {
                generalResponse.message = responseDecoded["mensaje"]["user"];
              }
            }
          } else {
            generalResponse.error = true;
            generalResponse.message = 'ERRORVERSION';
            debugPrint("ERROR DE VERSION");
            fp.alertContent = AlertOutdatedApplication(
                message: responseDecoded["version"]["mensaje"],
                urlAndroid: responseDecoded["version"]["url"],
                urliOS: responseDecoded["version"]["url"]);
          }
          break;
        case 307:
          generalResponse.error = true;
          generalResponse.message =
              "Ocurrió un error al consultar con los servicios. Intente con una red que le permita el acceso";
          break;
        default:
          generalResponse.error = true;
          generalResponse.message =
              "El servidor no responde. Intente más tarde.";
          break;
      }
      // return Future.error('HOLA');

      //return generalResponse;
    } on TimeoutException catch (e) {
      debugPrint('$e');
      generalResponse.error = true;
      generalResponse.message =
          'Tiempo de conexión excedido.'; //Config.getMessage("timeoutException");
    } on FormatException catch (ex, s) {
      debugPrint(ex.toString());
      generalResponse.error = true;
      generalResponse.message =
          'Ocurrió un error en el servidor, intente nuevamente.';
      FirebaseCrashlytics.instance.recordError(ex, s,
          reason: 'Se produjo un error de formato', fatal: true);
    } on SocketException catch (exSock) {
      Helper.logger.e("Error por conexion -> ${exSock.toString()}");
      generalResponse.error = true;
      generalResponse.message = "Error de Conexión";
    } on Exception catch (e, stacktrace) {
      FirebaseCrashlytics.instance.recordError(e, stacktrace,
          reason: 'Se produjo un error en la solicitud', fatal: true);
      debugPrint("Error en request -> ${stacktrace.toString()}");
      generalResponse.error = true;
      generalResponse.message = "Error...";
    }

    if (showLoading && !generalResponse.error) {
      if (context != null) {
        fp.dismissAlert();
      }
    }
    if (generalResponse.error) {
      if (generalResponse.message == 'ERRORVERSION') {
        fp.showAlert(content: fp.alertContent);
      } else {
        if (showAlertError) {
          fp.showAlert(
              content: AlertGenericError(
            message: generalResponse.message,
            messageButton: messageButton,
            onPress: onPress,
          ));
        } else {
          //fp.dismissAlert();
        }
      }
    }
    return generalResponse;
  }

  HttpClient getHttpClient() {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

//?
  Future<String> readResponseAsString(HttpClientResponse response) {
    var completer = Completer<String>();
    var contents = StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
      // print(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }
}
