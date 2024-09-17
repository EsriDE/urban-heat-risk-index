use std::env;

fn main() {
    match env::var("arcgis_api_key") {
        Ok(arcgis_api_key) => {
            println!("{}", arcgis_api_key)
        },
        Err(ex) => {
            println!("{}", ex)
        },
    }
}
