#[cfg(test)]
mod tests {
    use super::*;
    use serde_esri::places::query::{PlacesClient, WithinExtentQueryParamsBuilder, PLACES_API_URL};
    use std::env;

    #[test]
    fn test_env_var_exists() {
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
        let client = PlacesClient::new(PLACES_API_URL, "test_key");
        let params = WithinExtentQueryParamsBuilder::default()
            .xmin(139.74)
            .ymin(35.65)
            .xmax(139.75)
            .ymax(35.66)
            .build()
            .unwrap();
        
        let res = client.within_extent(params);
        assert!(res.is_ok());
    }
}