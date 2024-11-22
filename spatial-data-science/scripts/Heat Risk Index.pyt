# -*- coding: utf-8 -*-

import arcpy
from arcgis.geometry import Envelope
from heatri import calculate_heat_risk_index_using_extent


class Toolbox:
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "HRIToolbox"
        self.alias = "hritoolbox"

        # List of tool classes associated with this toolbox
        self.tools = [HRITool]


class HRITool:
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "HRI"
        self.description = "Calculates the heat risk index of an urban region."
    

    def getParameterInfo(self):
        """Define the tool parameters."""
        params = [
            # Extent parameter
            arcpy.Parameter(
                displayName="Input envelope",
                name="in_envelope",
                datatype="GPEnvelope",
                parameterType="Required",
                direction="Input"),

            # Derived output spatial bins
            arcpy.Parameter(
                displayName="Output features",
                name="out_features",
                datatype="GPFeatureLayer",
                parameterType="Derived",
                direction="Output")
        ]
        return params

    def isLicensed(self):
        """Set whether the tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter. This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        """The source code of the tool."""
        envelope = parameters[0].value
        
        # Get current map spatial reference
        focus_map = arcpy.mp.ArcGISProject("current").activeMap
        map_sr = focus_map.spatialReference
        envelope_of_interest = Envelope({
            "xmin": envelope.XMin,
            "ymin": envelope.YMin,
            "xmax": envelope.XMax,
            "ymax": envelope.YMax,
            "spatialReference": {
                "wkid": map_sr.factoryCode
            }
        })
        heat_risk_index_features = calculate_heat_risk_index_using_extent(envelope_of_interest)
        parameters[1].value = heat_risk_index_features

    def postExecute(self, parameters):
        """This method takes place after outputs are processed and
        added to the display."""
        return
