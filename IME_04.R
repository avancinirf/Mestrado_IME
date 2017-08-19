
### ---------------------------------------------------------------------
### Gerando Pontos para espécie virtual
### ---------------------------------------------------------------------

# Selecionando o diretório raiz
setwd("C:/Users/Ricardo Avancini/Documents/SDM_Elith_2017/especie_virtual")
getwd() 
# Exemplo do Tutorial
library("sdmvspecies")
library("raster")

# Carregando o arquivo tif do Nicho Ecológico
tif <- list.files(pattern = ".tif")
tif

# carregar os arquivos .tif
predictors <- stack(tif)
predictors
names(predictors)
# plot(predictors)
plot(predictors>0.7)


# Reclassify raster
# all values >= 0 and <= 0.25 become 1, etc.
rc_predictors <- reclassify(predictors, c(0,0.74,NA, 0.75,1,1))

# Carregando o pacote dismo para usar a função randomPoints
library(dismo)
specie <- randomPoints(rc_predictors, 45)

plot(rc_predictors)
points(specie, pch='+', col='red')

# Salva o arquivo tif com os dados reclassificados para ) ou 1 (>=0.75 = 1)
writeRaster(rc_predictors, paste0("rc_vs.tif"), format = "GTiff")

# Salva os pontos gerados como uma tabela
write.table(specie, "vs_pontos.csv", row.names = T, sep = ";")

#Transforma em spatial points 
specie = SpatialPoints(specie, proj4string=CRS("+proj=longlat +datum=WGS84")) 
ANTcoor.df <- SpatialPointsDataFrame(specie, data.frame(id=1:length(specie))) 

#Salva em shapefile 
writeOGR(ANTcoor.df, getwd(), 'especie_virtual', 'ESRI Shapefile') 




