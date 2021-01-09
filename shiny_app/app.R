library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(usmap)
library(dplyr)
library(readxl)

# Load voter turnout and Powerball data. 

voterData = as.data.frame(read_excel("../data/master.xlsx", sheet = "Turnout Rates"))
powerball = read_excel("../data/master.xlsx", sheet = "Powerball")

# Percentage adjustments to voter data.

voterData[, 'VEP Turnout Rate (Highest Office)'] = round(voterData[, 'VEP Turnout Rate (Highest Office)'] * 100)

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
        
        voterTurnout = round((input$votePercent/100) * voterData[voterData$state == input$state, "Voting-Eligible Population (VEP)"])
        probability = dbinom(round(voterTurnout*0.5), size = voterTurnout, prob = 0.5)
        paste("1 in ", round(1/probability), ', or ', round(probability*100, 4), "%", sep = "")
        
        })
    
    output$powerOdds = renderTable({
        
        voterTurnout = round((input$votePercent/100) * voterData[voterData$state == input$state, "Voting-Eligible Population (VEP)"])
        demProb = input$demPercent/100
        logProb = dbinom(round(voterTurnout*0.5), size = voterTurnout, prob = demProb, log = TRUE)
        powerball[,'More Likely to Win'] = paste(floor(logProb/log(powerball$Odds)), ' times', sep = '')
        powerball[,c('Match', 'Odds of Winning', 'Prize', 'More Likely to Win')]
        },
        
        bordered = TRUE,
        align = 'c',
        striped = TRUE,
        spacing = 'm',
        width = '100%'
        )
    
    output$map = renderPlotly({
       
        p = plot_usmap(data = voterData, values = 'VEP Turnout Rate (Highest Office)') + 
            scale_fill_continuous(name = "Voter Turnout (%)", label = scales::comma) +
            theme(legend.position = "right")
        
        ggplotly(p)
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
