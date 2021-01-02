#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# To Do:
# 1. Choropleth map of varying state odds.
# 2. Lottery comparisons.
# 3. Make it look "pretty".
# 4. Binomial distribution plot?

library(shiny)
library(leaflet)
library(maps)
library(dplyr)
library(readxl)


statePop = read_excel("../data/master.xlsx")
stateVect = statePop$Total
names(stateVect) = statePop$State
    
votingOdds = function(population){
    probability = dbinom(round(population*0.5), size = population, prob = 0.5)
    result = paste(round(probability*100, 4), "%", " or 1 in ", 
                   round(1/probability), sep = "")
    return(result)
}

ui <- fluidPage(
    titlePanel("Odds Your Vote Matters"),
    
    selectInput(inputId = "state", 
                label = "Pick Your State: ",
                choices = c("Alabama", "Alaska", "Arizona", "Arkansas", 
                            "California", "Colorado", "Connecticut", "Delaware",
                            "Florida", "Georgia", "Hawaii", "Idaho", "Illinois",
                            "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
                            "Maine", "Maryland", "Massachusetts", "Michigan",
                            "Minnesota", "Mississippi", "Missouri", "Montana",
                            "Nebraska", "Nevada", "New Hampshire", "New Jersey",
                            "New Mexico", "New York", "North Carolina", "North Dakota",
                            "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
                            "South Carolina", "South Dakota", "Tennessee", "Texas",
                            "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
                            "Wisconsin", "Wyoming")),
    
    sliderInput(inputId = "votePercent",
                label = "Percentage of Voters: ",
                min = 0,
                max = 100,
                value = 100),
    
    mainPanel(
        textOutput("odds")
    )
)


server <- function(input, output) {
    
    output$odds = renderText({
        totalVoters = input$votePercent * unname(stateVect[input$state])
        votingOdds(totalVoters)
        })

}

# Run the application 
shinyApp(ui = ui, server = server)
