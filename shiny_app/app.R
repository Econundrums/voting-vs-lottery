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
library(ggplot2)
library(maps)
library(dplyr)
library(readxl)

# Load population and US geo-coordinate data, and merge the dataframes.

statePop = read_excel("../data/master.xlsx")
statePop$region = tolower(statePop$State)
stateGeo = map_data("state")
mergedData = inner_join(statePop, stateGeo, by = 'region')

# Creating a named vector to easily call population data in the server.

stateVect = statePop$Population
names(stateVect) = statePop$State
    
votingOdds = function(pop){
    prob = dbinom(round(pop*0.5), size = pop, prob = 0.5)
    result = paste(round(prob*100, 4), "%", " or 1 in ", round(1/prob), sep = "")
    return(result)
}

ui <- fluidPage(
    titlePanel("Odds Your Vote Matters"),
    
    selectInput(inputId = "state", 
                label = "Pick Your State: ",
                choices = names(stateVect)),
    
    sliderInput(inputId = "votePercent",
                label = "Percentage of Voters: ",
                min = 0,
                max = 100,
                value = 100),
    
    mainPanel(
        textOutput("odds"),
        plotOutput("map")
    )
)


server <- function(input, output) {
    output$odds = renderText({
        totalVoters = input$votePercent * unname(stateVect[input$state])
        votingOdds(totalVoters)
        })
    
    output$map = renderPlot({           
        ggplot() + 
            geom_polygon(data = mergedData, 
                         aes(x = long, y = lat, group = group, fill = Population/1000000), 
                            color = 'white', size = 0.2)
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
