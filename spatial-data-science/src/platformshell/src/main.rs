use reqwest::Url;
use serde_esri::features::FeatureSet;
use serde_json::json;
use std::env;
use std::io::Read;



#[cfg(test)]
mod tests {
    use serde_esri::places::query::{PlacesClient, WithinExtentQueryParamsBuilder, PLACES_API_URL};
    use std::env;

    #[test]
    fn test_env_var_exists() {
        // Check whether or not an ArcGIS API key was set using the environment
        env::set_var("arcgis_api_key", "test_key");
        assert!(env::var("arcgis_api_key").is_ok());
    }

    #[test]
    fn test_within_extent_query_params_builder() {
        let params = WithinExtentQueryParamsBuilder::default()
            .xmin(139.74)
            .ymin(35.65)
            .xmax(139.75)
            .ymax(35.66)
            .build()
            .unwrap();
        
        assert_eq!(params.xmin, 139.74);
        assert_eq!(params.ymin, 35.65);
        assert_eq!(params.xmax, 139.75);
        assert_eq!(params.ymax, 35.66);
    }

    #[test]
    fn test_within_extent() {
        let arcgis_api_key = env::var("arcgis_api_key").unwrap();
        let client = PlacesClient::new(PLACES_API_URL, &arcgis_api_key);
        let params = WithinExtentQueryParamsBuilder::default()
            .xmin(-0.0765)
            .ymin(51.4945)
            .xmax(0.0364)
            .ymax(51.5254)
            .category_ids(vec!["17117".to_string()])
            .build()
            .unwrap();
        
        let res = client.within_extent(params);
        assert!(res.is_ok());
    }
}


fn main() -> Result<(), Box<dyn std::error::Error>> {
    let urban_hri_url = env::var("URBAN_HEAT_RISK_INDEX_FEATURE_SERVICE_URL")?;
    let query_url = Url::parse_with_params(
        &(urban_hri_url + "/query"),
        &[
            ("where", "1=1"),
            ("outFields", "*"),
            ("returnGeometry", "true"),
            ("resultRecordCount", "5"),
            ("f", "json"),
        ],
    )?;
    let mut response = reqwest::blocking::get(query_url)?;
    let mut body = String::new();

    // Read the request into a String
    response.read_to_string(&mut body)?;

    //println!("{:?}", body);

    // Parse into a 2D FeatureSet
    let hri_featureset: FeatureSet<2> = serde_json::from_str(&body)?;

     // Extract and print the JSON representation of the geometries
     for hri_feature in hri_featureset.features {
        if let Some(hri_geometry) = hri_feature.geometry {
            if let Some(polygon) = hri_geometry.as_polygon() {
                let json_geometry = json!(polygon);
                println!("{}", serde_json::to_string_pretty(&json_geometry)?);
            } else {
                eprintln!("Geometry is not a polygon.");
            }
        }
    }

    Ok(())
}
