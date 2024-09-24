use geo::Point;
use platformshell::LocationServicesError;
use reqwest::Url;
use serde_esri::features::FeatureSet;
use serde_json::json;
use serde_json::Value;
use std::env;
use std::io::Read;

mod utils;



#[cfg(test)]
mod tests {
    use serde_esri::places::query::{PlacesClient, WithinExtentQueryParamsBuilder, PLACES_API_URL};
    use std::env;

    #[test]
    fn test_env_var_exists() {
        // Check whether or not an ArcGIS API key was set using the environment
        //env::set_var("arcgis_api_key", "test_key");
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
    // Create a Point with latitude and longitude
    let location = Point::new(7.116004, 50.719847);

    // Query the feature service
    let urban_hri_url = env::var("URBAN_HEAT_RISK_INDEX_FEATURE_SERVICE_URL")?;
    
    match utils::query_heat_risk_index(urban_hri_url, location) {
        Ok(hri_featureset) => {
            let json = serde_json::to_string_pretty(&hri_featureset)?;
            println!("{}", json);
        }
        Err(e) => {
            eprintln!("Error querying heat risk index: {}", e);
            return Err(Box::new(LocationServicesError { code:9999, message:"Error querying heat risk index!".to_string() }));
        }
    }

    Ok(())
}