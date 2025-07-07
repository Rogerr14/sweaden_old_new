import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:camera/camera.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as g_places;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
// import 'package:awesome_select/awesome_select.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/login/pages/login_page.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/pages/offline_configuration_page.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_response.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_storage.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/services/media_service.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/widget_animation.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';

import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/request_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
//? CUSTOM CAMERA
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    as gmlkit;
import 'package:sweaden_old_new_version/shared/widgets/camera/camera_provider.dart';
import 'package:sweaden_old_new_version/shared/widgets/rotating_icon_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:video_player/video_player.dart';

import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../secured_storage/offline_data_storage.dart';

part 'text_field.dart';
part 'background_app.dart';
part 'select.dart';
part 'bottom_info.dart';
part 'google_map.dart';
part 'search_places.dart';
part 'alert_modal.dart';
part 'alerts_templates.dart';
part 'calendar.dart';
part 'notification.dart';
part 'notification_expiration_catalogue.dart';
part 'camera/camera_widget.dart';
