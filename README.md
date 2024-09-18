# Urban Heat Risk Index

## Overview

Welcome to the **Urban Heat Risk Index** repository! This project aims to raise awareness about the phenomenon of Urban Heat Islands (UHIs) and identify these hotspots using advanced Location Intelligence techniques powered by ArcGIS.

## What are Urban Heat Islands?

Urban Heat Islands are areas within urban environments that experience significantly higher temperatures than their rural surroundings. This temperature difference is primarily due to human activities, dense infrastructure, and limited vegetation. UHIs can exacerbate heatwaves, increase energy consumption, and negatively impact public health.

## Project Goals

1. **Raise Awareness**: Educate the public and policymakers about the causes and consequences of Urban Heat Islands.
2. **Identify UHIs**: Utilize Location Intelligence and ArcGIS to pinpoint areas most affected by UHIs.
3. **Mitigate Risks**: Provide data-driven insights to help develop strategies for mitigating the adverse effects of UHIs.

## How It Works

### Data Collection

We gather data from various sources, including satellite imagery, weather stations, and urban infrastructure databases. This data is then processed and analyzed using ArcGIS to create detailed heat maps.

### Analysis

Using ArcGIS, we apply spatial analysis techniques to identify patterns and correlations between urban features and temperature variations. This helps us pinpoint specific areas that are most susceptible to the UHI effect.

![Screenshot ModelBuilder Heat Risk Index](https://raw.githubusercontent.com/EsriDE/urban-heat-risk-index/main/doc/img/HRI.svg)
*Screenshot: ModelBuilder Heat Risk Index*

### Visualization

The results are visualized through interactive maps and dashboards, making it easy for stakeholders to understand the extent and impact of UHIs in their regions.

## Getting Started

### Prerequisites

- [ArcGIS Location Platform](https://location.arcgis.com)
- Basic knowledge of GIS and Spatial Data Science

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/EsriDE/urban-heat-risk-index.git
   ```
2. Navigate to the project directory:
   ```bash
   cd urban-heatrisk-index
   ```
3. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

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
