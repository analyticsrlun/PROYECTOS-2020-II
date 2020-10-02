


ui <- fluidPage(
  
  tabsetPanel(
    tabPanel("Random Forest", "",
            
     # Sidebar layout with a input and output definitions
       sidebarLayout(
      
      # Inputs: Select variables to plot
          sidebarPanel(
            
            
            #actionButton(inputId = "Run",label =  "Run Model!"),
          #  br(),
          # br(),
                 
            selectInput(inputId = "MACHINE_ID", 
                        label = "Machine ID:",
                        choices = as.character(1:144), 
                        selected = 1),
            
            numericInput(inputId = "Lifetime",
                         label = "Días desde el ultimo mantenimiento:" ,
                         min = 0,
                         max = 10000, step = 1,value = 20),
            
            selectInput(inputId = "MAINT_EQUP", 
                        label = "Maintenance Team:",
                        choices = levels(dataset$Maintenance.equipment), 
                        selected = 3),
            
            selectInput(inputId = "Supplier", 
                        label = "Supplier:",
                        choices = levels(as.factor(dataset$Supplier)), 
                        selected = 2),
            
            submitButton(" Apply changes", icon("check-square"))
            
            
            
            
            
             # Show data table
             #  checkboxInput(inputId = "show_data",
             #               label = "Show data table",
             #              value = TRUE)
               ),
               
               # Output
               mainPanel(
                 
                 textOutput(outputId = "prueba"),
                 
                 tags$h1(textOutput(outputId = "texto")),
                 br(),
                 
                 plotlyOutput(outputId = "control_plot"),
                 
                 
                 br()
                 
                 
                 
                 
               )
             )
             
             
             
             
             
             
             ),
    tabPanel("Graficas Analisis Descriptivo", "",
        
             
             fluidPage(
               fluidRow(
                 column(6,
                     
                        br(),
                        plotOutput(outputId = "barra"),
                        
                 ),
                 column(6,
                        
                        br(),
                        plotOutput(outputId = "bp1")
                        
                        
               )
               
             
               
               
             
#              
#              sidebarLayout(
#                
#                # Inputs: Select variables to plot
#                 sidebarPanel(
#                  
#                             ), 
#                 mainPanel(
# )
#                         )
             
             )
    ),
  
  

)

)
)
