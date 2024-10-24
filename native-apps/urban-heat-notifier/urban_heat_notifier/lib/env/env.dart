import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
    @EnviedField(varName: 'APIKEY', obfuscate: true)
    static final String apikey = _Env.apikey;
}