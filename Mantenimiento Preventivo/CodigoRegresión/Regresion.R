########## Tratamiento de los datos ###########
if (!require(dplyr)) install.packages("dplyr")
require(dplyr)

# Importe
rowdata <- read.csv('lathes_data.csv')

#Nombres amables
names(rowdata)
rowdata <- rename(rowdata, Machine.number = ï..Machine.number, Equipment = Maintenance.equipment, 
       Lifetime = Time..days.) 

#Info que interesa
rowdata <- filter(rowdata, !(Faults == 0)) #Para sólo quedarnos con los tiempos de falla


########## Exploración Inicial ##########
if (!require(ggplot2)) install.packages("gglot2")
require(ggplot2)

bp1 <- ggplot(data = rowdata, aes(x = Supplier, y = Lifetime, group = Supplier)) + 
  geom_boxplot()
bp1

bp2 <- ggplot(data = rowdata, aes(x = Equipment, y = Lifetime, group = Equipment)) + 
  geom_boxplot()
bp2

########## Preparación del Dataset para regresión ##########

#Variables Categóricas para Supplier
S1 = 0; S2 = 0; S3 = 0; S4 = 0; k = 1
for (i in rowdata$Supplier) {
  if (i == 1) { S1[k] = 1 } else S1[k] = 0
  
  if (i == 2) { S2[k] = 1 } else S2[k] = 0
  
  if (i == 3) { S3[k] = 1 } else S3[k] = 0
  
  if (i == 4) { S4[k] = 1 } else S4[k] = 0
  
  k <- k + 1
  
}

#Variables Categóricas para Equipo de Mantenimiento
EA = 0; EB = 0; EC = 0; k = 1
for (i in rowdata$Equipment) {
  if (i == "A") { EA[k] = 1 } else EA[k] = 0
  
  if (i == "B") { EB[k] = 1 } else EB[k] = 0
  
  if (i == "C") { EC[k] = 1 } else EC[k] = 0
  
  k <- k + 1
  
}

#Dataset para la Regresión
d <- data.frame(select(rowdata, Machine.number, Lifetime), S1, S2, S3, S4, EA, EB, EC)


########## Empieza la Regresión #############

fit <- lm(Lifetime ~ S2 + S3 + S4 + EB + EC, data = d)
summary(fit)

df <- data.frame(Variable = c("S2", "S3", "S4", "EB", "EC"), 
                 Coefficient = fit$coefficients[2:6])
 
p <- ggplot(data = df, aes(x = Variable, y = Coefficient)) + 
  geom_bar(stat = 'identity', color = 'blue', fill = 'steelblue') + 
  labs(y = 'Influence in Lifetime (days)', title = 'Influencia de cada factor en Lifetime')
  
p

########## Dataset para modelo de ML ##########

#Se puede simplemente exportar d

write.csv(d, "datos.csv")


