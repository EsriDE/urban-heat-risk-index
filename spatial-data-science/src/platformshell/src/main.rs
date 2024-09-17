use serde_esri::places::query::PlacesClient;
use serde_esri::places::query::WithinExtentQueryParamsBuilder;
use serde_esri::places::query::PLACES_API_URL;
use std::env;

fn main() {
    match env::var("arcgis_api_key") {
        Ok(arcgis_api_key) => {
            let client = PlacesClient::new(
                PLACES_API_URL,
                &arcgis_api_key,
            );
        
            // Use the query within extent query builder to create query parameters
            let params = WithinExtentQueryParamsBuilder::default()
                .xmin(139.74)
                .ymin(35.65)
                .xmax(139.75)
                .ymax(35.66)
                .build()
                .unwrap();
        
            // Call the within_extent method with the query parameters
            let res = client.within_extent(params).unwrap();
        
            // use the automatic pagination for the iterator method
            res.into_iter()
                .for_each(|r| println!("{:?}", r.unwrap().name));
        },
        Err(ex) => {
            println!("{}", ex)
        },
    }
}
