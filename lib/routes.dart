import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/loading/pages/loading_page.dart';
import 'package:sweaden_old_new_version/modules/login/pages/login_page.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/new_request.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/pages/upload_inspections_page.dart';

import 'modules/offline_configuration/pages/offline_configuration_page.dart';



var customRoutes = <String, WidgetBuilder> {
  'loading': (_) => const LoadingPage(),
  'login': (_) => const LoginPage(),
  'home': (_) => const HomePage(),
  'new-request': (_) => const NewRequestPage(),
  'review-request': (_) => const ReviewRequestPage(),
  'offline-configuration': (_) => const OfflineConfigurationPage(),
  'cargar-inspecciones': (_) => const UploadInspectionsPage()
};
