### Analysis

Using ArcGIS, we apply spatial analysis techniques to identify patterns and correlations between urban features and temperature variations. This helps us pinpoint specific areas that are most susceptible to the UHI effect.

The following screenshot shows the model to calculate the urban heat risk index based on landsat imagery, landcover and population data.

![Screenshot ModelBuilder Heat Risk Index](https://raw.githubusercontent.com/EsriDE/urban-heat-risk-index/main/doc/img/HRI.svg)
*Screenshot: ModelBuilder Heat Risk Index*

### Setup heat risk index

Install the `heatri` module using pip:
```
pip install --user .
```

```python

from arcgis.features import GeoAccessor
from heatri import calculate_heat_risk_index_using_extent

# Calculates the heat risk index using an extent
extent = {
    'spatialReference': {
        'latestWkid': 3857,
        'wkid': 102100
    },
    'xmin': 789781.3584458455,
    'ymin': 6573897.888560204,
    'xmax': 790368.9681008684,
    'ymax': 6574136.754273627
}
heat_risk_index_features = calculate_heat_risk_index_using_extent(extent)
hri_sdf = GeoAccessor.from_featureclass(heat_risk_index_features)
hri_sdf
```