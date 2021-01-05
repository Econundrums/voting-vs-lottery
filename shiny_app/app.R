#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# To Do:
# 2. Lottery comparisons.
# 3. Make it look "pretty".

library(shiny)
library(ggplot2)
library(maps)
library(dplyr)
library(readxl)

# Load population, US geo-coordinate, and Powerball data. 

statePop = read_excel("../data/master.xlsx", sheet = "State Pop 18+")
powerball = read_excel("../data/master.xlsx", sheet = "Powerball")
stateGeo = map_data("state")

# Merge population and geo-coordinate data.

statePop$region = tolower(statePop$State)
mergedData = inner_join(statePop, stateGeo, by = 'region')

# Creating a named vector to easily call population data in the server.

stateVect = statePop$Population
names(stateVect) = statePop$State

ui <- fluidPage(
    titlePanel("Voting Sucks"),
    
    sidebarPanel(
        selectInput(inputId = "state", 
                    label = "State: ",
                    choices = names(stateVect)),
        
        sliderInput(inputId = "votePercent",
                    label = "Voter Turnout (%): ",
                    min = 0,
                    max = 100,
                    value = 100),
        
        sliderInput(inputId = "demPercent",
                    label = "Democrat Candidate Bias (%): ",
                    min = 0,
                    max = 100,
                    value = 50),
        
        helpText("Odds Your Vote Matters"),
        textOutput("odds"),
        ),

    mainPanel(
        tableOutput("powerOdds")
    )
)


server <- function(input, output) {
    
    output$odds = renderText({
        population = round((input$votePercent/100) * unname(stateVect[input$state]))
        probability = dbinom(round(population*0.5), size = population, prob = 0.5)
        paste(round(probability*100, 4), "%", " or 1 in ", round(1/probability), 
              sep = "")
        })
    
    output$powerOdds = renderTable({
        population = round((input$votePercent/100) * unname(stateVect[input$state]))
        demProb = input$demPercent/100
        logProb = dbinom(round(population*0.5), size = population, prob = demProb, log = TRUE)
        powerball[,'More Likely to Win'] = paste(floor(logProb/log(powerball$Odds)), ' times', sep = '')
        powerball[,c('Match', 'Odds of Winning', 'Prize', 'More Likely to Win')]
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
