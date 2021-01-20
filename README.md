# Don't Vote. Play the Lottery Instead.

Inspired by this [old Slate article](https://slate.com/culture/2004/09/don-t-vote-play-the-lottery-instead.html), as well as constant harrassment from the "eVeRy vOtE cOuNtS!!!" zealots, this RShiny app allows users to see just how little their individual vote matters in the Presidential General Election.

[Requirements](#requirements)

[How to Use the App](#instructions)

[The Math Behind the Numbers](#math)

[About the Data](#data)

<a name="requirements"></a>

### Requirements

If you just want to play around with the app itself, go [here](http://econundrums-rshiny.com/shiny/voting/shiny_app/).

If you want to tinker with the code yourself, you'll need to have [R installed](https://www.r-project.org/) along with the following packages.

```r
install.packages(c("shiny", "shinythemes", "ggplot2", "plotly", "usmap", "dplyr", "readxl"))
```
If the above code snippet doesn't work, try installing each of the above packages individually (e.g. `install.packages('shiny')`).

For ease of use, especially if you're a beginner, I <b>strongly</b> recommend you also download [RStudio Desktop](https://rstudio.com/products/rstudio/download/) after you download R, then open and launch the app from there.

<a name="instructions"></a>

### How to Use the App

<b>Control Widgets</b>

* <i>State</i>: Choose your state, which will query its respective voting eligible population (VEP) from the master spreadsheet/database (which is also included in this repository).   

* <i>Voter Turnout (%):</i> Set the % of voter turnout for a state's given VEP. If you're unsure what your chosen state's voter turnout is, there's a choropleth map of the USA included that will give you an estimate based on voter turnout for the 2020 General presidential election.

* <i> Bias Towards Democrats (%):</i> Set the % of total voters that vote for the Democratic candidate. For example, a selection of 51% means 51% of the total voters will vote for the Democratic candidate and 49% will vote for the Republican one. A completely unbiased electorate will have this option set at 50%. Unfortunately, unlike voter turnout, there's no graph or feature yet that will provide a suggested value if you don't already have an idea of your state's preferences. Seeking to add this in the future. 

<b>Outputs</b>

* <i>Odds</i>: Below the "Bias Towards Democrats (%)" will be the odds your vote makes a difference in the nomination of the president. By making a difference, I mean the odds the outcome of the election will be determined by one vote. Only the "State" and "Voter Turnout (%)" widgets affect this value.

* <i>Powerball Table</i>: To the right of the input panel is a table showing your odds of winning various Powerball prizes relative to your selections. The only column affected will be the one titled "More Likely to Win", which tells you how much more likely you will win <i>consecutively</i> given your choices. All control widgets in the input panel affect these numbers.

<a name="math"></a>

### The Math Behind the Numbers

To be continued...

<a name="data"></a>

### About the Data

To be continued...
