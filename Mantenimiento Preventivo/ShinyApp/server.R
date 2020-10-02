library(caTools)
library(shiny)
library(randomForest)
library(plotly)

min <- 0 ; num <- 1; datafr<-data.frame(0);

load("Data_Maintenance.RData")

dataset1 <- rename(dataset, Ref_Maquina=Machine.number, Equipo=Maintenance.equipment,
                  Proveedor=Supplier, Tiempo_Falla=Time..days., Falla=Faults)
dataset1$Ref_Maquina <- factor(dataset1$Ref_Maquina)
dataset1$Equipo <- factor(dataset1$Equipo)
dataset1$Proveedor <- factor(dataset1$Proveedor)
dataset1$Falla <- factor(dataset1$Falla)

shinyServer(function(input,output){
  
  
  classifier <- randomForest(x = training_set[-5],
                            y = training_set$Faults,
                            ntree =10,keep.forest = T)
  
  output$RandomForest <- renderPlot({

      plot(classifier)

  })
  
  output$texto <- renderText({

  for (i in 1:110) {
    
    datafr[i,1] <-as.numeric(predict(classifier, c("Machine.number"=as.numeric(input$MACHINE_ID),
                                            "Maintenance.equipment"=as.numeric(input$MAINT_EQUP),
                                            "Supplier"=as.numeric(input$Supplier),
                                            "Time..days."=i), type="class") )
    datafr[i,2] <- i
    
  }
  colnames(datafr) <- c("a","b")
  

  as.character(paste("El número de días esperado antes del siguiente fallo es ",max(0,110-sum(datafr[,1]==max(datafr[,1]))-as.numeric(input$Lifetime))," días"))
  #as.character(paste("El número de días esperado antes del siguiente fallo es ",sum(if_else(datafr[,1]<0.85,TRUE,FALSE))," o ",max(0,110-sum(datafr[,1]==max(datafr[,1]))-as.numeric(input$Lifetime))," días"))
    # "F to pay respects"
  }) 
  
  output$control_plot <- renderPlotly({
    
    for (i in 1:140) {
      
      datafr[i,1] <-as.numeric(predict(classifier, c("Machine.number"=as.numeric(input$MACHINE_ID),
                                                     "Maintenance.equipment"=as.numeric(input$MAINT_EQUP),
                                                     "Supplier"=as.numeric(input$Supplier),
                                                     "Time..days."=i), type="class") )
      datafr[i,2] <- i
      
    }
    colnames(datafr) <- c("Prob","Días");
    
    ggplotly(ggplot(datafr)+ geom_area(aes(x=`Días`,y=Prob), alpha= 0.3, color="grey25", fill = "dodgerblue4") + xlab("Días desde el último mantenimiento") + ylab("Probabilidad de fallo")+
     theme_bw() + theme(axis.title = element_text(size = 15))) # theme(panel.background = element_rect(fill = "white"),axis.ticks = element_line(colour = "gray15"))
    
  })
  
  output$prueba <- renderText({
    
    input$Run
  })
  
  output$barra <- renderPlot({
    
    
    #1) Diagramas de Barra
    ggplot(dataset, aes(x=Faults,  fill=`Maintenance.equipment`)) +      
      geom_bar(position="dodge",colour="black")+
      labs(y="",title="Reports per year by supplier and team")+
      #guides(fill=FALSE)+
      #scale_fill_manual(values = c("red","blue", "orange"))+
      ylim(c(0,80))+
      geom_text(aes(label=..count..),stat='count',position=position_dodge(0.9),
                vjust=-0.5, size=3.0)+
      facet_wrap(~Supplier)+theme_bw(base_size = 15)+
      theme(text = element_text(family = "Muli",size = 10),
            plot.title = element_text(size = 15),legend.position = "bottom") 
    })
    
    output$bp1 <- renderPlot({ ggplot(data = dataset1, aes(x = Proveedor, y = Tiempo_Falla, group = Proveedor, color=Proveedor)) + 
      geom_boxplot() + 
      labs(x="Proveedor", y="Tiempo hasta fallar", title = "Tiempo de falla por proveedores") + theme_bw(base_size = 15) +
      theme(text = element_text(family = "Muli",size = 10),
            plot.title = element_text(size = 15),legend.position = "bottom") 
                            }
      )
    
    # output$bp2 <- renderPlot({ 
    #   
    #   ggplot(dataset,aes(x=`Time..days.`,y=`Maintenance.equipment`))+
    #     geom_boxplot(fill = NA, color = "white", width = 0.4, size = 0.3, outlier.color = NA)+
    #     geom_violin(aes(color = `Maintenance.equipment`, fill = `Maintenance.equipment`))+
    #     xlim(0,120)+facet_wrap(~Supplier)+
    #     theme(text = element_text(family = "Muli",size = 10),
    #           plot.title = element_text(size = 15))+
    #     labs(title = "Ponle el titulo tu Mario xd")
    #   
    #   }   )
    # 
    
    
    
    
  })
 


