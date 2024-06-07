# Load required libraries
library(shiny)
library(leaflet)
library(dplyr)
library(readr)
library(rworldmap)
library(shinydashboard)
library(shinythemes)
library(RColorBrewer)
library(countrycode)

# Read the CSV file
AirPolData <- readr::read_csv("https://raw.githubusercontent.com/RohanBaghel10/Air-Pollution-Shiny-app/main/data/death-rate-from-air-pollution-per-100000.csv") %>%
  rename(Deaths_per_100k = "Deaths that are from all causes attributed to air pollution per 100,000 people, in both sexes aged age-standardized")

# Standardize country names in the dataset
AirPolData <- AirPolData %>%
  mutate(CountryCode = countrycode(Entity, "country.name", "iso3c"))

# Get the country coordinates and shapes
world_map <- getMap(resolution = "low")

# Standardize country names in the world map
world_map@data$ISO3 <- countrycode(world_map@data$ADMIN, "country.name", "iso3c")

# Define the UI
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Air Pollution Deaths Worldwide"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("globe")),
      menuItem("Country Data", tabName = "country", icon = icon("flag"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(
                box(
                  title = "Select Year", status = "primary", solidHeader = TRUE,
                  selectInput("year", "Year:", 
                              choices = sort(unique(AirPolData$Year)),
                              selected = min(AirPolData$Year, na.rm = TRUE))
                )
              ),
              leafletOutput("map", height = 800)
      ),
      tabItem(tabName = "country",
              fluidRow(
                box(
                  title = "Select Country", status = "primary", solidHeader = TRUE,
                  selectInput("country", "Country:", 
                              choices = sort(unique(AirPolData$Entity)),
                              selected = "United States")
                )
              ),
              dataTableOutput("country_table")
      )
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Reactive data based on the selected year
  filteredData <- reactive({
    AirPolData %>% filter(Year == input$year)
  })
  
  # Reactive data based on the selected country
  countryData <- reactive({
    AirPolData %>% filter(Entity == input$country)
  })
  
  # Render the leaflet map
  output$map <- renderLeaflet({
    leaflet(world_map) %>%
      addTiles() %>%
      setView(lng = 0, lat = 20, zoom = 2)
  })
  
  observe({
    # Get filtered data for the selected year
    data <- filteredData()
    
    # Merge the data with the world map
    merged_data <- merge(world_map@data, data, by.x = "ISO3", by.y = "CountryCode", all.x = TRUE)
    world_map@data <- merged_data
    
    # Define color palette
    pal <- colorBin(palette = "YlOrRd", domain = world_map@data$Deaths_per_100k, bins = 5, na.color = "transparent")
    
    # Update the map with polygons
    leafletProxy("map", data = world_map) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(Deaths_per_100k),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7
      ) %>%
      addLegend(pal = pal, values = ~Deaths_per_100k, opacity = 0.7, title = "Deaths per 100k",
                position = "bottomright")
  })
  
  # Render the country data table
  output$country_table <- renderDataTable({
    countryData()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)