import 'package:http/http.dart' as http;

import 'client_factory_io.dart'
    if (dart.library.js_interop) 'client_factory_web.dart';

http.Client createHttpClient() => createPlatformClient();
