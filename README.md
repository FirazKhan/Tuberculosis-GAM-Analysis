# Tuberculosis (TB) Data Analysis using GAMs - Brazil Microregions

A comprehensive statistical analysis of tuberculosis prevalence in Brazilian microregions using Generalized Additive Models (GAMs) with spatial and temporal components.

## Overview

This project analyzes tuberculosis (TB) data from Brazilian microregions to identify patterns, risk factors, and spatial-temporal trends. The analysis employs sophisticated statistical modeling techniques including Generalized Additive Models (GAMs) to understand the relationship between TB rates and various socio-economic factors.

## Features

- **Comprehensive Data Exploration**: Statistical summaries and visualization of TB rates across regions and time
- **Correlation Analysis**: Examination of relationships between socio-economic covariates
- **Multiple GAM Models**: Progressive modeling approach including:
  - Basic GAM with socio-economic covariates
  - Spatial GAM with geographic smoothing
  - Spatio-temporal GAM with time-varying spatial effects
- **Model Comparison**: Statistical comparison using AIC and likelihood ratio tests
- **Risk Mapping**: Visualization of TB risk across geographic regions
- **Resource Allocation Analysis**: Identification of high-risk regions for targeted interventions
- **Temporal Trend Analysis**: Evolution of TB rates over time

## Dependencies

The analysis requires R with the following packages:

```r
mgcv          # For GAM modeling
fields        # For spatial analysis
maps          # For mapping
sp            # For spatial data
ggplot2       # For plotting
dplyr         # For data manipulation
viridis       # For color schemes
reshape2      # For data reshaping
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/tb-gam-analysis.git
cd tb-gam-analysis
```

2. Install required R packages:
```r
install.packages(c("mgcv", "fields", "maps", "sp", "ggplot2", 
                   "dplyr", "viridis", "reshape2"))
```

## Usage

1. Ensure the data file `datasets_project.RData` is in the project directory

2. Run the complete analysis:
```r
source("code.R")
```

The script will:
- Load and explore the TB data
- Generate visualizations of TB rates
- Perform correlation analysis of socio-economic variables
- Fit and compare multiple GAM models
- Produce diagnostic plots and model summaries
- Identify high-risk regions
- Save results to `TB_analysis_results.RData`

## Data Description

The analysis uses TB data from Brazilian microregions with the following variables:

### Response Variable
- **TB**: Number of tuberculosis cases
- **TB_rate**: TB cases per population (derived)
- **log_TB_rate**: Log-transformed TB rate for modeling

### Geographic Variables
- **lon**: Longitude coordinate
- **lat**: Latitude coordinate

### Temporal Variable
- **Year**: Year of observation (2013-2014)

### Socio-economic Covariates
- **Population**: Regional population
- **Indigenous**: Proportion of indigenous population
- **Illiteracy**: Illiteracy rate
- **Urbanisation**: Urbanization level
- **Density**: Population density
- **Poverty**: Poverty rate
- **Poor_Sanitation**: Proportion with poor sanitation
- **Unemployment**: Unemployment rate
- **Timeliness**: Healthcare timeliness indicator

## Methodology

The analysis follows a systematic approach:

1. **Data Preparation**
   - Data cleaning and transformation
   - Creation of TB rate variable
   - Log transformation for modeling

2. **Exploratory Analysis**
   - Spatial visualization of TB rates
   - Distribution analysis
   - Temporal trends examination
   - Correlation analysis of covariates

3. **Model Building**
   - **Model 1**: Basic GAM with socio-economic covariates and year factor
   - **Model 2**: Addition of spatial smooth (lon, lat)
   - **Model 3**: Addition of spatio-temporal interaction

4. **Model Selection**
   - AIC comparison
   - Likelihood ratio tests
   - Diagnostic plots (residuals, Q-Q plots, response vs. fitted)

5. **Results Interpretation**
   - Identification of significant risk factors
   - Spatial risk mapping
   - High-risk region identification for resource allocation

## Results

The analysis produces:

- **Correlation heatmap** of socio-economic variables
- **Spatial maps** of TB rates and predictions
- **Model diagnostic plots** for all GAM models
- **Temporal trend visualizations**
- **High-risk region identification** (95th percentile residuals)
- **Comprehensive model summaries** with statistical significance tests

### Key Outputs

- Model comparison statistics (AIC values)
- Significant socio-economic predictors
- Spatial and temporal patterns
- Resource allocation recommendations

## Files in Repository

- `code.R` - Main analysis script
- `datasets_project.RData` - Input data file
- `README.md` - This file
- `report.docx` - Detailed report (Word format)
- `TB_Report_Final.html` - HTML report
- `Thameem Ansari-Mohammed Firaz-750011330.pdf` - Final PDF report

## Model Details

### GAM Formula Structure

**Model 1 (Basic)**:
```r
log_TB_rate ~ s(Indigenous) + s(Illiteracy) + s(Urbanisation) + 
              s(Density) + s(Poverty) + s(Poor_Sanitation) + 
              s(Unemployment) + s(Timeliness) + Year_fac
```

**Model 2 (Spatial)**:
```r
log_TB_rate ~ [covariates] + Year_fac + s(lon, lat)
```

**Model 3 (Spatio-temporal)**:
```r
log_TB_rate ~ [covariates] + Year_fac + s(lon, lat) + s(lon, lat, by=Year_fac)
```


## License

This project is part of an academic assignment. Please contact the authors for usage permissions.

## Acknowledgments

- Data source: Brazilian TB surveillance system
- Course: Statistical Data Modelling (MSc)
- Analysis framework: mgcv package by Simon Wood

---

For questions or issues, please open an issue in the GitHub repository.

