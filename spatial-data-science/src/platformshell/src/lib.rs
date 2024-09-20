use std::fmt;

#[derive(Debug)]
pub struct LocationServicesError {
    pub code: i32,
    pub message: String,
}

impl fmt::Display for LocationServicesError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "ArcGIS Location Platform Error {}: {}", self.code, self.message)
    }
}

impl std::error::Error for LocationServicesError {}