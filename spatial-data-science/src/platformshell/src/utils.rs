use geo::Point;
use platformshell::LocationServicesError;
use reqwest::Url;
use serde_esri::features::FeatureSet;
use serde_json::json;
use serde_json::Value;
use std::io::Read;



pub fn query_heat_risk_index(urban_hri_url: String, location: Point) -> Result<FeatureSet<2>, Box<dyn std::error::Error>> {
    let location_str = format!("{}, {}", location.x(), location.y());
    let location_wkid_str = "4326";

    // Query the feature service
    let out_fields = "HRI, TEMP";
    let query_url = Url::parse_with_params(
        &(urban_hri_url + "/query"),
        &[
            ("where", "1=1"),
            ("geometryType", "esriGeometryPoint"),
            ("geometry", &location_str),
            ("inSR", &location_wkid_str),
            ("outFields", &out_fields),
            ("returnGeometry", "true"),
            ("f", "json"),
        ],
    )?;
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
    let mut filtered_features = Vec::new();

    // Extract and print the JSON representation of the features
    for hri_feature in &hri_featureset.features {
        if let Some(hri_attributes) = &hri_feature.attributes {
            for (key, value) in hri_attributes.iter() {
                println!("{}: {}", key, value);
            }
        }
        if let Some(hri_geometry) = &hri_feature.geometry {
            if let Some(polygon) = hri_geometry.clone().as_polygon() {
                let json_geometry = json!(polygon);
                filtered_features.push(hri_feature.clone());
                println!("{}", serde_json::to_string_pretty(&json_geometry)?);
            } else {
                //eprintln!("Geometry is not a polygon.");
                return Err(Box::new(LocationServicesError { code:9999, message:"Geometry is not a polygon.".to_string() }));
            }
        }
    }

    Ok(FeatureSet {
        objectIdFieldName: hri_featureset.objectIdFieldName.clone(),
        globalIdFieldName: hri_featureset.globalIdFieldName.clone(),
        displayFieldName: hri_featureset.displayFieldName.clone(),
        spatialReference: hri_featureset.spatialReference.clone(),
        geometryType: hri_featureset.geometryType.clone(),
        features: filtered_features,
        fields: hri_featureset.fields.clone(),
    })
}
