import arcpy
from arcpy.sa import *
from arcpy import Extent
from arcpy import SpatialReference
from sys import argv

def initialize_arcpy():
    """ Initialize arcpy settings and check necessary extensions. """
    arcpy.env.overwriteOutput = True
    arcpy.CheckOutExtension("3D")
    arcpy.CheckOutExtension("spatial")
    arcpy.CheckOutExtension("ImageAnalyst")

def generate_tessellation(output_feature_class, extent, size, spatial_ref):
    """ Generate a tessellation grid. """
    arcpy.management.GenerateTessellation(
        Output_Feature_Class=output_feature_class,
        Extent=extent,
        Size=size,
        Spatial_Reference=spatial_ref
    )

def spatial_join(target_features, join_features, out_feature_class):
    """ Perform a spatial join between two feature sets. """
    arcpy.analysis.SpatialJoin(
        target_features=target_features,
        join_features=join_features,
        out_feature_class=out_feature_class,
        match_option="LARGEST_OVERLAP"
    )

def zonal_statistics(in_zone_data, zone_field, in_value_raster, out_table, statistics_type="MAXIMUM"):
    """ Calculate zonal statistics as a table. """
    arcpy.sa.ZonalStatisticsAsTable(
        in_zone_data,
        zone_field,
        in_value_raster,
        out_table,
        "DATA",
        statistics_type
    )

def copy_raster(in_raster, out_rasterdataset, raster_format="TIFF"):
    """ Copy a raster to a new dataset. """
    arcpy.management.CopyRaster(in_raster, out_rasterdataset, format=raster_format)

def reclassify_raster(in_raster, remap, out_raster):
    """ Reclassify a raster based on value ranges. """
    reclass_raster = arcpy.sa.Reclassify(in_raster, "Value", remap)
    reclass_raster.save(out_raster)

def join_field(in_data, in_field, join_table, join_field, fields):
    """ Join fields from one table to another. """
    arcpy.management.JoinField(
        in_data=in_data,
        in_field=in_field,
        join_table=join_table,
        join_field=join_field,
        fields=fields
    )

def calculate_field(in_table, field, expression, field_type="FLOAT"):
    """ Calculate a new field based on an expression. """
    arcpy.management.CalculateField(
        in_table=in_table,
        field=field,
        expression=expression,
        field_type=field_type
    )

def standardize_field(in_table, fields, method="MIN-MAX", min_value=1, max_value=5):
    """ Standardize fields using the given method. """
    arcpy.management.StandardizeField(
        in_table=in_table,
        fields=fields,
        method=method,
        min_value=min_value,
        max_value=max_value
    )

#def delete_features(in_features):
#    """ Delete features from a feature class or layer. """
#    arcpy.management.DeleteFeatures(in_features=in_features)

def hri_main(landsat_surf_temp, land_cover, zensus_2022, extent, spatial_reference, workspace=None):
    """ Main function to execute the HRI analysis. """
    initialize_arcpy()

    if workspace is None: 
        arcpy.env.workspace = arcpy.env.scratchGDB
    else: 
        arcpy.env.workspace = workspace
  
    # Generate tessellation
    tessellation_output = "HRI_Hexagone"
    generate_tessellation(
        output_feature_class=tessellation_output, 
        extent=extent,
        size="1500 SquareMeters",
        spatial_ref=spatial_reference
    )
   
    # Spatial join
    spatial_join_output = "HRI_Hexagone_SpatialJoin1"
    spatial_join(tessellation_output, zensus_2022, spatial_join_output)
    surf_temp_layer = "Landsat Surface Temperature"
    arcpy.management.MakeImageServerLayer(landsat_surf_temp, surf_temp_layer, processing_template="Band 10 Surface Temperature in Celsius", template=extent)

    # Zonal statistics for surface temperature
    surf_temp_table_output = "surf_temp_max"
    zonal_statistics(spatial_join_output, "GRID_ID", surf_temp_layer, surf_temp_table_output)
    return

    # Copy raster for tree canopy
    copy_raster(land_cover, "tree_canopy.tif")

    # Reclassify tree canopy raster
    reclassify_raster("tree_canopy.tif", "10 1;20 0;30 0;40 0;50 0;60 0;70 0;80 0;90 0;95 0;100 0", "reclass_tree_canopy.tif")

    # Zonal statistics for reclassified tree canopy
    tree_canopy_count = "tree_canopy_count"
    zonal_statistics(spatial_join_output, "GRID_ID", "reclass_tree_canopy.tif", tree_canopy_count, statistics_type="SUM")

    # Join fields for tree canopy statistics
    join_field(spatial_join_output, "GRID_ID", tree_canopy_count, "GRID_ID", ["SUM"])

    # Calculate percentage tree cover and lacking
    calculate_field(tree_canopy_count, "PCT_Tree_Cover", "(!SUM! / !COUNT!) * 100")
    calculate_field(tree_canopy_count, "PCT_Lacking", "100 - !PCT_Tree_Cover!")

    # Join the fields for surface temperature and tree canopy data
    join_field(spatial_join_output, "GRID_ID", surf_temp_max, "GRID_ID", ["MAX"])
    join_field(spatial_join_output, "GRID_ID", tree_canopy_count, "GRID_ID", ["PCT_Tree_Cover", "PCT_Lacking"])

    # Copy raster for built-up area
    copy_raster(land_cover, "built_up_area.tif")

    # Reclassify built-up area raster
    reclassify_raster("built_up_area.tif", "10 0;20 0;30 0;40 0;50 1;60 0;70 0;80 0;90 0;95 0;100 0", "reclass_built_up_area.tif")

    # Zonal statistics for reclassified built-up area
    built_up_area_count = "built_up_area_count"
    zonal_statistics(spatial_join_output, "GRID_ID", "reclass_built_up_area.tif", built_up_area_count, statistics_type="SUM")

    # Join the built-up area statistics
    join_field(spatial_join_output, "GRID_ID", built_up_area_count, "GRID_ID", ["SUM"])
    calculate_field(built_up_area_count, "PCT_built_up_area", "(!SUM! / !COUNT!) * 100")
    join_field(spatial_join_output, "GRID_ID", built_up_area_count, "GRID_ID", ["PCT_built_up_area"])

    # Final HRI calculation using standardized values
    standardize_field(
        spatial_join_output,
        [["Einwohner", "Einwohner_MIN_MAX"], ["MAX", "TEMP_MAX_MIN_MAX"], ["PCT_Lacking", "PCT_Lacking_MIN_MAX"]]
    )
    calculate_field(spatial_join_output, "HRI", "Sum($feature.TEMP_MAX_MIN_MAX, $feature.PCT_Lacking_MIN_MAX, $feature.Einwohner_MIN_MAX)", field_type="FLOAT")

    # Select layer by location
  #  arcpy.management.SelectLayerByLocation(
  #      in_layer=[spatial_join_output],
  #      overlap_type="WITHIN",
  #      select_features="Ortsteile_Bonn",
  #      invert_spatial_relationship="INVERT"
  #  )

    # Delete features not in Bonn
   # delete_features(spatial_join_output)

if __name__ == '__main__':
    #hri_main(*argv[1:])
    landsat_surf_temp = "https://landsat2.arcgis.com/arcgis/rest/services/Landsat/MS/ImageServer"
    land_cover = "https://tiledimageservices.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/European_Space_Agency_WorldCover_2021_Land_Cover_WGS84_7/ImageServer"
    zensus_2022 = "https://services2.arcgis.com/jUpNdisbWqRpMo35/arcgis/rest/services/Zensus2022_grid_final/FeatureServer/0"
    spatial_reference = SpatialReference(102100)
    extent = Extent(XMin=788871.95069623261, YMin=6576847.6816084972, XMax=790779.65876141505, YMax=6577625.2997531621, spatial_reference=spatial_reference)
    


    hri_main(landsat_surf_temp, land_cover, zensus_2022, extent, spatial_reference)

