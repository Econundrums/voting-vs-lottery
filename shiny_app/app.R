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
    
    # State name to abbreviation conversion
    state_abbr <- c(
        "Alabama" = "AL", "Alaska" = "AK", "Arizona" = "AZ", "Arkansas" = "AR",
        "California" = "CA", "Colorado" = "CO", "Connecticut" = "CT", "Delaware" = "DE",
        "Florida" = "FL", "Georgia" = "GA", "Hawaii" = "HI", "Idaho" = "ID",
        "Illinois" = "IL", "Indiana" = "IN", "Iowa" = "IA", "Kansas" = "KS",
        "Kentucky" = "KY", "Louisiana" = "LA", "Maine" = "ME", "Maryland" = "MD",
        "Massachusetts" = "MA", "Michigan" = "MI", "Minnesota" = "MN", "Mississippi" = "MS",
        "Missouri" = "MO", "Montana" = "MT", "Nebraska" = "NE", "Nevada" = "NV",
        "New Hampshire" = "NH", "New Jersey" = "NJ", "New Mexico" = "NM", "New York" = "NY",
        "North Carolina" = "NC", "North Dakota" = "ND", "Ohio" = "OH", "Oklahoma" = "OK",
        "Oregon" = "OR", "Pennsylvania" = "PA", "Rhode Island" = "RI", "South Carolina" = "SC",
        "South Dakota" = "SD", "Tennessee" = "TN", "Texas" = "TX", "Utah" = "UT",
        "Vermont" = "VT", "Virginia" = "VA", "Washington" = "WA", "West Virginia" = "WV",
        "Wisconsin" = "WI", "Wyoming" = "WY", "District of Columbia" = "DC"
    )
    
    # Add abbreviations to data
    voterData$state_abbr <- state_abbr[voterData$state]
    
    # Prepare hover text
    voterData$hover_text <- paste0(
        "<b>", voterData$state, "</b><br>",
        "Voter Turnout: ", voterData$`VEP Turnout Rate (Highest Office)`, "%<br>",
        "Eligible Population: ", format(voterData$`Voting-Eligible Population (VEP)`, big.mark = ",")
    )
    
    # Create plotly choropleth map
    plot_ly(
        data = voterData,
        type = "choropleth",
        locations = ~state_abbr,
        locationmode = "USA-states",
        z = ~`VEP Turnout Rate (Highest Office)`,
        text = ~hover_text,
        hovertemplate = "%{text}<extra></extra>",
        colorscale = list(c(0, "lightblue"), c(1, "darkblue")),
        colorbar = list(title = "Voter Turnout (%)")
    ) %>%
    layout(
        geo = list(
            scope = "usa",
            projection = list(type = "albers usa"),
            showlakes = TRUE,
            lakecolor = toRGB("white")
        )
    )
    
})
    
}

# Run the application 
shinyApp(ui = ui, server = server)
