#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# To Do:
# 3. Make it look "pretty".
# 4. Get choropleth map highlighting different state voter turnouts.
# 5. Swap between light and dark theme?

library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(usmap)
library(dplyr)
library(readxl)

# Load voter turnout and Powerball data. 

voterData = as.data.frame(read_excel("../data/master.xlsx", sheet = "Voter Turnout"))
powerball = read_excel("../data/master.xlsx", sheet = "Powerball")

# Percentage adjustments to voter data.

voterData$democratic_bias = round(voterData$democratic_bias * 100)
voterData$vep_total_ballots_counted = round(voterData$vep_total_ballots_counted * 100)

ui <- fluidPage(
    titlePanel("Don't Vote. Play the Lottery Instead."),
    theme = shinytheme("cosmo"),
    
    sidebarPanel(
        selectInput(inputId = "state", 
                    label = "State: ",
                    choices = voterData$state),
        
        sliderInput(inputId = "votePercent",
                    label = "Voter Turnout (%): ",
                    min = 0,
                    max = 100,
                    value = 100),
        
        sliderInput(inputId = "demPercent",
                    label = "Bias Towards Democrats (%): ",
                    min = 0,
                    max = 100,
                    value = 50),
        
        radioButtons(inputId = 'mapOptions',
                     label = "Choose Map Data",
                     choices = c("Voter Turnout", "Bias Towards Democrats")
        ),
        
        helpText("Odds Your Vote Matters"),
        textOutput("odds"),
        
        ),

    mainPanel(
        tableOutput("powerOdds"),
        plotlyOutput("map")
    )
)


server <- function(input, output) {
    
    output$odds = renderText({
        
        voterTurnout = round((input$votePercent/100) * voterData[voterData$state == input$state, "vep"])
        probability = dbinom(round(voterTurnout*0.5), size = voterTurnout, prob = 0.5)
        paste("1 in ", round(1/probability), ', or ', round(probability*100, 4), "%", sep = "")
        
        })
    
    output$powerOdds = renderTable({
        voterTurnout = round((input$votePercent/100) * voterData[voterData$state == input$state, "vep"])
        demProb = input$demPercent/100
        logProb = dbinom(round(voterTurnout*0.5), size = voterTurnout, prob = demProb, log = TRUE)
        powerball[,'More Likely to Win'] = paste(floor(logProb/log(powerball$Odds)), ' times', sep = '')
        powerball[,c('Match', 'Odds of Winning', 'Prize', 'More Likely to Win')]
        },
        
        bordered = TRUE,
        align = 'c',
        striped = TRUE,
        spacing = 'm',
        width = '100%')
    
    output$map = renderPlotly({
        if (input$mapOptions == 'Voter Turnout'){
            p = plot_usmap(data = voterData, values = "vep_total_ballots_counted") + 
                scale_fill_continuous(name = "Voter Turnout (%)", label = scales::comma) +
                theme(legend.position = "right")
        }
        else{
            p = plot_usmap(data = voterData, values = "democratic_bias") + 
                scale_fill_continuous(low = "red", high = "blue", name = "Bias Towards Democrats (%)", label = scales::comma, breaks = c(0, 25, 50, 75, 100), limits = c(0, 100)) +
                theme(legend.position = "right")
        }
        
        ggplotly(p)
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
