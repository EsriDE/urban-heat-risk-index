
from .heat_risk_index import hri_main
from arcpy import Extent, SpatialReference


def calculate_heat_risk_index(x_min: float, y_min: float, x_max: float, y_max: float, wkid: int) -> str:
    """
    Calculates the heat risk index for a defined geographic region.

    :return: The local path to the calculated heat risk index spatial bin features.
    """

    landsat_surf_temp = "https://landsat2.arcgis.com/arcgis/rest/services/Landsat/MS/ImageServer"
    land_cover = "https://tiledimageservices.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/European_Space_Agency_WorldCover_2021_Land_Cover_WGS84_7/ImageServer"
    zensus_2022 = "https://services2.arcgis.com/jUpNdisbWqRpMo35/arcgis/rest/services/Zensus2022_grid_final/FeatureServer/0"

    spatial_reference = SpatialReference(wkid)
    extent = Extent(XMin=x_min, YMin=y_min, XMax=x_max, YMax=y_max, spatial_reference=spatial_reference)
    hri_spatial_bins = hri_main(landsat_surf_temp, land_cover, zensus_2022, extent, spatial_reference)
    return hri_spatial_bins