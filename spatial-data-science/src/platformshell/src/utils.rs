use geo::Point;
use platformshell::LocationServicesError;
use reqwest::Url;
use serde_esri::features::{Feature, FeatureSet};
use serde_json::Value;
use std::io::Read;



pub fn query_heat_risk_index<F>(urban_hri_url: String, where_clause: &str, location: Option<Point>, filter_fn: F) -> Result<FeatureSet<2>, Box<dyn std::error::Error>> where F: Fn(&Feature<2>) -> bool, {   
    // Query the feature service
    let query_url;
    let out_fields = "HRI, TEMP";
    if let Some(spatial_filter_location) = location {
        let location_str = format!("{}, {}", spatial_filter_location.x(), spatial_filter_location.y());
        let location_wkid_str = "4326";

        query_url = Url::parse_with_params(
            &(urban_hri_url + "/query"),
            &[
                ("where", where_clause),
                ("geometryType", "esriGeometryPoint"),
                ("geometry", &location_str),
                ("inSR", &location_wkid_str),
                ("outFields", &out_fields),
                ("returnGeometry", "true"),
                ("f", "json"),
            ],
        )?;
    } else {
        query_url = Url::parse_with_params(
            &(urban_hri_url + "/query"),
            &[
                ("where", where_clause),
                ("outFields", &out_fields),
                ("returnGeometry", "true"),
                ("f", "json"),
            ],
        )?;
    }
    let mut response = reqwest::blocking::get(query_url)?;
    let mut body = String::new();

    // Read the request into a String
    response.read_to_string(&mut body)?;

    // Parse the response body as JSON
    let json_body: Value = serde_json::from_str(&body)?;

    // Check if the JSON contains an error
    if let Some(error) = json_body.get("error") {
        let code = error.get("code").and_then(Value::as_i64).unwrap_or(0) as i32;
        let message = error.get("message").and_then(Value::as_str).unwrap_or("Unknown error").to_string();
        //eprintln!("{}", message);
        return Err(Box::new(LocationServicesError { code, message }));
    }
    //println!("{:?}", body);

    // Parse into a 2D FeatureSet
    let hri_featureset: FeatureSet<2> = serde_json::from_str(&body)?;

    // Filter features using the provided closure
    let filtered_features: Vec<Feature<2>> = hri_featureset
        .features
        .into_iter()
        .filter(|feature| filter_fn(feature))
        .collect();

    // Create a new FeatureSet with the filtered features
    let filtered_featureset = FeatureSet {
        objectIdFieldName: hri_featureset.objectIdFieldName,
        globalIdFieldName: hri_featureset.globalIdFieldName,
        displayFieldName: hri_featureset.displayFieldName,
        spatialReference: hri_featureset.spatialReference,
        geometryType: hri_featureset.geometryType,
        features: filtered_features,
        fields: hri_featureset.fields,
    };

    Ok(filtered_featureset)
}
