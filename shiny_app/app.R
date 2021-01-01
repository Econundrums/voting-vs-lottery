#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(dplyr)


ui <- fluidPage(
    titlePanel("Odds Your Vote Matters"),
    
    selectInput(inputId = "state", 
                label = "State: ",
                choices = c("Alabama" = "AL",
                            "Alaska" = "AK",
                            "Arizona" = "AZ",
                            "Arkansas" = "AR",
                            "California" = "CA",
                            "Colorado" = "CO",
                            "Connecticut" = "CT",
                            "Delaware" = "DE",
                            "Florida" = "FL",
                            "Georgia" = "GA",
                            "Hawaii" = "HI",
                            "Idaho" = "ID",
                            "Illinois" = "IL",
                            "Indiana" = "IN",
                            "Iowa" = "IA",
                            "Kansas" = "KS",
                            "Kentucky" = "KY",
                            "Louisiana" = "LA",
                            "Maine" = "ME",
                            "Maryland" = "MD",
                            "Massachusetts" = "MA",
                            "Michigan" = "MI",
                            "Minnesota" = "MN",
                            "Mississippi" = "MS",
                            "Missouri" = "MO",
                            "Montana" = "MT",
                            "Nebraska" = "NE",
                            "Nevada" = "NV",
                            "New Hampshire" = "NH",
                            "New Jersey" = "NJ",
                            "New Mexico" = "NM",
                            "New York" = "NY",
                            "North Carolina" = "NC",
                            "North Dakota" = "ND",
                            "Ohio" = "OH",
                            "Oklahoma" = "OK",
                            "Oregon" = "OR",
                            "Pennsylvania" = "PA",
                            "Rhode Island" = "RI",
                            "South Carolina" = "SC",
                            "South Dakota" = "SD",
                            "Tennessee" = "TN",
                            "Texas" = "TX",
                            "Utah" = "UT",
                            "Vermont" = "VT",
                            "Virginia" = "VA",
                            "Washington" = "WA",
                            "West Virginia" = "WV",
                            "Wisconsin" = "WI",
                            "Wyoming" = "WY")),
    mainPanel(
        textOutput("odds")
    )
)


server <- function(input, output) {
    
    probability = dbinom(round(1000 * 0.5), size = 1000, prob = 0.5)
    
    output$odds = renderText({
        case_when(
            input$state == "CA" ~ probability,
            input$state == "AK" ~ 0.05
        )
        
        })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
