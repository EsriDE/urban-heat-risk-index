import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
    @EnviedField(varName: 'APIKEY', obfuscate: true)
    static String apikey = _Env.apikey;
    @EnviedField(varName: 'TITLE', obfuscate: false)
    static String title = _Env.title;
    @EnviedField(varName: 'INITIALVIEWPOINT', obfuscate: false)
    static String initialViewPont = _Env.initialViewPont;
    @EnviedField(varName: 'BASEMAP', obfuscate: false)
    static String basemap = _Env.basemap;
    @EnviedField(varName: 'HriVectorTileServicePortalItemID', obfuscate: false)
    static String hriVectorTileServicePortalItemID = _Env.hriVectorTileServicePortalItemID;
    @EnviedField(varName: 'HriFeatureServicePortalItemID', obfuscate: false)
    static String hriFeatureServicePortalItemID = _Env.hriFeatureServicePortalItemID;
    @EnviedField(varName: 'DrinkingWaterFeatureServicePortalItemID', obfuscate: false)
    static String drinkingWaterFeatureServicePortalItemID = _Env.drinkingWaterFeatureServicePortalItemID;
    @EnviedField(varName: 'PlacesServiceUrl', obfuscate: false)
    static String placesServiceUrl = _Env.placesServiceUrl;
    @EnviedField(varName: 'PlacesSearchRadius', obfuscate: false)
    static String placesSearchRadius = _Env.placesSearchRadius;
    @EnviedField(varName: 'PlacesCategoryIds', obfuscate: false)
    static String placesCategoryIds = _Env.placesCategoryIds;

}