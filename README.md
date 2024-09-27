# Urban Heat Risk Index

## Overview

Welcome to the **Urban Heat Risk Index** repository! This project aims to raise awareness about the phenomenon of Urban Heat Islands (UHIs) and identify these hotspots using advanced Location Intelligence techniques powered by ArcGIS.

## What are Urban Heat Islands?

Urban Heat Islands are areas within urban environments that experience significantly higher temperatures than their rural surroundings. This temperature difference is primarily due to human activities, dense infrastructure, and limited vegetation. UHIs can exacerbate heatwaves, increase energy consumption, and negatively impact public health.

## What is Urban Heat Risk Index?
By analyzing temperature data, population density, and tree coverage, the Heat Risk Index helps to identify areas most at risk during extreme heat events.

The calculated index is based on this [Blog](https://www.esri.com/arcgis-blog/products/arcgis-pro/imagery/heat-resilience-planning-part-1/).

If you are interested in creating and customizing your own index, [this page](https://learn.arcgis.com/en/projects/customize-a-climate-resilience-index/) might be the right place.

## Project Goals

1. **Raise Awareness**: Educate the public and policymakers about the causes and consequences of Urban Heat Islands.
2. **Identify UHIs**: Utilize Location Intelligence and ArcGIS to pinpoint areas most affected by UHIs.
3. **Mitigate Risks**: Provide data-driven insights to help develop strategies for mitigating the adverse effects of UHIs.

## How It Works

### Data Collection

We gather data from various sources, including satellite imagery, weather stations, and urban infrastructure databases. This data is then processed and analyzed using ArcGIS to create detailed heat risk maps.

### Analysis

Using ArcGIS, we apply spatial analysis techniques to identify patterns and correlations between urban features and temperature variations. This helps us pinpoint specific areas that are most susceptible to the UHI effect.

The following screenshot shows the model to calculate the urban heat risk index based on landsat imagery, landcover and population data.

![Screenshot ModelBuilder Heat Risk Index](https://raw.githubusercontent.com/EsriDE/urban-heat-risk-index/main/doc/img/HRI.svg)
*Screenshot: ModelBuilder Heat Risk Index*

### Visualization

The results are visualized through interactive maps and dashboards, making it easy for stakeholders to understand the extent and impact of UHIs in their regions.

![Screenshot Notebook Heat Risk Index](https://github.com/user-attachments/assets/7fea4ad1-a20c-4bcc-b1d5-035fc2b61ec4)

*Screenshot: ArcGIS API for Python Heat Risk Index*

## Getting Started

### Prerequisites

- [ArcGIS Location Platform](https://location.arcgis.com)
- Basic knowledge of GIS and Spatial Data Science

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/EsriDE/urban-heat-risk-index.git
   ```
2. Stay tuned...

### Usage

1. Load your data into ArcGIS.
2. Run the analysis scripts provided in the `scripts` directory.
3. Visualize the results using the templates in the `visualizations` directory.

## Contributing

We welcome contributions from anyone and everyone. Please see our [guidelines for contributing](CONTRIBUTING.md).

## License

This project is licensed under the Apache V2 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

We would like to thank the ArcGIS community and all the contributors who have helped make this project possible.
