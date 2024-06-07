# Air Pollution Data Dashboard

## Overview
This dashboard provides insights into air pollution data sourced from [Our World in Data](https://ourworldindata.org/air-pollution). It allows users to visualize and compare air pollution-related death rates across different countries, explore summary statistics, and view data for random countries.

## Data Source
The data used in this dashboard is sourced from [Our World in Data's air pollution dataset](https://ourworldindata.org/air-pollution). It includes information about air pollution-related deaths per 100,000 people, aggregated by country and year.

## Features
- **Dashboard Tab**: Allows users to select and compare air pollution-related death rates between two countries over time using line plots or bar plots.
- **Summary Tables Tab**: Provides summary statistics (mean, median, minimum, maximum) for death rates per 100,000 people for each selected country.
- **Random Country Data Tab**: Displays data for a randomly selected country, along with a histogram of death rates per 100,000 people.
- **World Map Tab**: Presents an interactive world map highlighting countries based on their air pollution-related death rates.

## Technologies Used
- **R Programming Language**: Used for data processing, analysis, and visualization.
- **Shiny**: A web application framework for R, used for building the interactive dashboard.
- **Plotly**: A visualization library used to create interactive plots, including the world map.

## How to Use
1. Clone or download the repository to your local machine.
2. Open the R script (`app.R`) in RStudio or any R environment.
3. Install the required packages mentioned in the script if not already installed.
4. Run the script to launch the Shiny application.
5. Navigate through different tabs to explore the data and visualizations.

## Acknowledgments
- Data Source: [Our World in Data - Air Pollution](https://ourworldindata.org/air-pollution)

## License
This project is licensed under the [MIT License](LICENSE).
