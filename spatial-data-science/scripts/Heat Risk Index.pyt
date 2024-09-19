# -*- coding: utf-8 -*-

import arcpy
from heat_risk_index import initialize_arcpy


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
        self.description = ""
        initialize_arcpy() 
    

    def getParameterInfo(self):
        """Define the tool parameters."""
        params = None
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
        return

    def postExecute(self, parameters):
        """This method takes place after outputs are processed and
        added to the display."""
        return
