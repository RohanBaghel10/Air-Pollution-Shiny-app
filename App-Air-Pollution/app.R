library(shiny)
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(shinythemes)

# Read the CSV file and rename column
AirPolData <- readr::read_csv("https://raw.githubusercontent.com/RohanBaghel10/Air-Pollution-Shiny-app/main/data/death-rate-from-air-pollution-per-100000.csv") %>%
  rename(Deaths_per_100k = "Deaths that are from all causes attributed to air pollution per 100,000 people, in both sexes aged age-standardized")

# Define UI
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Air Pollution Deaths"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Summary Tables", tabName = "summary_tables", icon = icon("table")),
      menuItem("Random Country Data", tabName = "random_data", icon = icon("random"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "dashboard",
        fluidRow(
          box(
            selectInput("country1", "Select first country:", choices = unique(AirPolData$Entity)),
            width = 6
          ),
          box(
            selectInput("country2", "Select second country:", choices = unique(AirPolData$Entity)),
            width = 6
          )
        ),
        fluidRow(
          box(
            selectInput("plot_type", "Select plot type:", choices = c("Line Plot", "Bar Plot")),
            width = 12
          )
        ),
        fluidRow(
          box(
            plotOutput("plot")
          )
        ),
        fluidRow(
          box(
            dataTableOutput("raw_data_table")
          )
        )
      ),
      tabItem(
        tabName = "summary_tables",
        fluidRow(
          box(
            dataTableOutput("summary_table1")
          )
        ),
        fluidRow(
          box(
            dataTableOutput("summary_table2")
          )
        )
      ),
      tabItem(
        tabName = "random_data",
        fluidRow(
          column(width = 6,
                 sliderInput("bin_size", "Bin Size:", min = 1, max = 50, value = 10)),
          column(width = 6,
                 actionButton("show_random", "Show Random Country Data"))
        ),
        fluidRow(
          box(
            tableOutput("random_country_table")
          ),
          box(
            plotOutput("random_country_plot")
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  output$plot <- renderPlot({
    # Filter data for selected countries
    country1_data <- filter(AirPolData, Entity == input$country1)
    country2_data <- filter(AirPolData, Entity == input$country2)
    
    # Create plot
    if (input$plot_type == "Line Plot") {
      p <- ggplot() +
        geom_line(data = country1_data, aes(x = Year, y = Deaths_per_100k), color = "blue") +
        geom_line(data = country2_data, aes(x = Year, y = Deaths_per_100k), color = "red") +
        labs(title = paste("Air Pollution Deaths Comparison"),
             x = "Year",
             y = "Deaths per 100,000 people") +
        scale_color_manual(values = c("blue", "red"), labels = c(input$country1, input$country2))
    } else {
      p <- ggplot() +
        geom_bar(data = rbind(country1_data, country2_data), aes(x = Year, y = Deaths_per_100k, fill = Entity), position = "dodge", stat = "identity") +
        labs(title = paste("Air Pollution Deaths Comparison"),
             x = "Year",
             y = "Deaths per 100,000 people")
    }
    
    print(p)
  })
  
  output$summary_table1 <- renderDataTable({
    # Extract data for selected country 1
    country1_data <- filter(AirPolData, Entity == input$country1)
    
    # Compute summary statistics for country 1
    summary_stats_country1 <- summary(country1_data$Deaths_per_100k)
    
    # Create summary table for country 1
    data.frame(
      Measure = c("Mean", "Median", "Minimum", "Maximum"),
      Value = c(summary_stats_country1["Mean"],
                summary_stats_country1["Median"],
                min(country1_data$Deaths_per_100k),
                max(country1_data$Deaths_per_100k))
    )
  })
  
  output$summary_table2 <- renderDataTable({
    # Extract data for selected country 2
    country2_data <- filter(AirPolData, Entity == input$country2)
    
    # Compute summary statistics for country 2
    summary_stats_country2 <- summary(country2_data$Deaths_per_100k)
    
    # Create summary table for country 2
    data.frame(
      Measure = c("Mean", "Median", "Minimum", "Maximum"),
      Value = c(summary_stats_country2["Mean"],
                summary_stats_country2["Median"],
                min(country2_data$Deaths_per_100k),
                max(country2_data$Deaths_per_100k))
    )
  })
  
  output$raw_data_table <- renderTable({
    # Combine data for selected countries
    selected_data <- rbind(
      filter(AirPolData, Entity == input$country1),
      filter(AirPolData, Entity == input$country2)
    )
    
    selected_data
  })
  
  observeEvent(input$show_random, {
    random_country <- sample(unique(AirPolData$Entity), 1)
    random_data <- filter(AirPolData, Entity == random_country)
    output$random_country_table <- renderTable({
      random_data
    })
    output$random_country_plot <- renderPlot({
      ggplot(random_data, aes(x = Deaths_per_100k)) +
        geom_histogram(binwidth = input$bin_size, fill = "skyblue", color = "black") +
        labs(title = paste("Histogram of Deaths per 100,000 People -", random_country), x = "Deaths per 100,000 People", y = "Frequency")
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
