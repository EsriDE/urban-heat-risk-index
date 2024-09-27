from .heat_risk_index import hri_main
from arcgis.geometry import Envelope
from arcpy import Extent as PyExtent, SpatialReference as PySpatialReference
import json
import os



def calculate_heat_risk_index_using_extent(extent: Envelope) -> str:
    """
    Calculates the heat risk index for a defined geographic region.

    :return: The local path to the calculated heat risk index spatial bin features.
    """

    landsat_surf_temp = "https://landsat2.arcgis.com/arcgis/rest/services/Landsat/MS/ImageServer"
    land_cover = "https://tiledimageservices.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/European_Space_Agency_WorldCover_2021_Land_Cover_WGS84_7/ImageServer"
    zensus_2022 = "https://services2.arcgis.com/jUpNdisbWqRpMo35/arcgis/rest/services/Zensus2022_grid_final/FeatureServer/0"

    if not 'spatialReference' in extent:
        raise ValueError('The extent has no spatial reference!')
    
    extent_spatial_reference = extent['spatialReference']
    if not 'wkid' in extent_spatial_reference:
        raise ValueError('The extent has no wkid!')
    
    wkid = extent_spatial_reference['wkid']
    spatial_reference = PySpatialReference(wkid)
    extent = PyExtent(XMin=extent['xmin'], YMin=extent['ymin'], XMax=extent['xmax'], YMax=extent['ymax'], spatial_reference=spatial_reference)
    hri_spatial_bins = hri_main(landsat_surf_temp, land_cover, zensus_2022, extent, spatial_reference)
    return hri_spatial_bins

def calculate_heat_risk_index(x_min: float, y_min: float, x_max: float, y_max: float, wkid: int) -> str:
    """
    Calculates the heat risk index for a defined geographic region.

    :return: The local path to the calculated heat risk index spatial bin features.
    """

    landsat_surf_temp = "https://landsat2.arcgis.com/arcgis/rest/services/Landsat/MS/ImageServer"
    land_cover = "https://tiledimageservices.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/European_Space_Agency_WorldCover_2021_Land_Cover_WGS84_7/ImageServer"
    zensus_2022 = "https://services2.arcgis.com/jUpNdisbWqRpMo35/arcgis/rest/services/Zensus2022_grid_final/FeatureServer/0"

    spatial_reference = PySpatialReference(wkid)
    extent = PyExtent(XMin=x_min, YMin=y_min, XMax=x_max, YMax=y_max, spatial_reference=spatial_reference)
    hri_spatial_bins = hri_main(landsat_surf_temp, land_cover, zensus_2022, extent, spatial_reference)
    return hri_spatial_bins

def generate_renderer() -> dict:
    """
    Generates the heat index renderer.

    :return: The class breaks renderer as dict.
    """

    with open(os.path.join(os.path.dirname(__file__), 'data', 'hri-renderer.json'), mode='r', encoding='utf8') as in_stream:
        return json.load(in_stream)