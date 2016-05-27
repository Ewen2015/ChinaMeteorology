#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# set your own work directory

library(shiny)
library(leaflet)

# load data and preprocess data
data = read.csv("https://raw.githubusercontent.com/Ewen2015/ChinaMeteorology/master/data/sample_pressure.csv", header = T)
data = data[-c(which(data$averagePressure == 999999)),]

data$averagePressure = data$averagePressure/10
data$popup = paste("站台站区号:", data$stationID, ";",
                   "本站累年年平均气压:", data$averagePressure, "hPa")
data$averagePressure = data$averagePressure - min(data$averagePressure)

data$lat = data$lat/100
data$long = data$long/100

# build the app
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points")
)

server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(lng=data$long, lat=data$lat)
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet(data) %>% addTiles() %>%
      addCircles(lng = ~long, lat = ~lat, weight = 1,
                 radius = ~averagePressure*100, popup = ~popup
      )
  })
}

# run app
shinyApp(ui, server)

