import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/pages/offline_configuration_page.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/plate_observation_service.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/alert_observations_plate_widget.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/widget_animation.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
// import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/inspection_detail.dart';
import 'package:sweaden_old_new_version/modules/review_request/providers/review_request_provider.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/micro-widgets/take_pick_video.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_storage.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/providers/media_form_provider.dart';

import 'package:sweaden_old_new_version/shared/helpers/helper.dart';

import 'package:sweaden_old_new_version/shared/models/media_info_response.dart';
import 'package:sweaden_old_new_version/shared/models/client_response.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/vehicles_data_inspection.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as gmlkit;
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/request_bitacora_services.dart';
import 'list_bitacora_widget.dart';

// import 'package:video_player/video_player.dart';

part 'list_inspection_widgets.dart';
part 'detail_inspection_widgets.dart';
part 'buttons_inspection_widgets.dart';
part 'reject_inspection_modal_widgets.dart';
part 'personal_data_form_widgets.dart';
part 'contact_information_form_widgets.dart';
part 'actives_data_form_widgets.dart';
part 'vehicles_data_form_widgets.dart';
part 'vehicles_accessories_data_form_widgets.dart';
part 'vehicles_data_2_form_widgets.dart';
part 'accessories_vehicles_modal_widgets.dart';
part 'media form/media_form.dart';
part 'invoice_detail_form_widget.dart';
part 'emit_polize_modal_widgets.dart';
part 'otp_modal_widgets.dart';
part 'facial_recognition_form.dart';
part 'factura_form.dart';
