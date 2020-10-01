library(png)
library(shiny)

ui <- fluidPage(
    # App title ----
    titlePanel("Interfaz para utilizar Red Neuronal"),
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        # Sidebar panel for inputs ----
        sidebarPanel(
            # Input: File upload
            
            fileInput("myFile", "Inserte una imagen png por favor", accept = c('image/png')),
        ),
        mainPanel(
            img(src="rstudio.png")
        )
    )
)

# Define server logic required to draw a histogram ----
server <- shinyServer(function(input, output,session){
    observeEvent(input$myFile, {
        inFile <- input$myFile
        if (is.null(inFile))
            return()
        file.copy(inFile$datapath, file.path("/home/ruedastorga/Descargas/Mini_Project/FOLDER", inFile$name) )
    })
})

shinyApp(ui, server)
