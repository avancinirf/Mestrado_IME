
### ---------------------------------------------------------------------
### Gerando Pontos para espécie virtual
### ---------------------------------------------------------------------

# Selecionando o diretório raiz
setwd("C:/Users/Ricardo/Documents/Mestrado_IME/especie_virtual")
getwd() 
# Exemplo do Tutorial
library("sdmvspecies")
library("raster")

# Carregando o arquivo tif do Nicho Ecológico
tif <- list.files(pattern = ".tif")
tif

# carregar os arquivos .tif
vs <- stack(tif)
vs
names(vs)
# plot(predictors)
plot(vs>0.95)


# Reclassify raster
# all values >= 0 and <= 0.25 become 1, etc.
rc_vs <- reclassify(vs, c(0,0.94,NA, 0.95,1,1))

# Carregando o pacote dismo para usar a função randomPoints
library(dismo)
require(rgdal)
library(rgeos)
specie <- randomPoints(rc_vs, 50)

plot(rc_vs)
points(specie, pch='+', col='red')

# Salva o arquivo tif com os dados reclassificados para ) ou 1 (>=0.75 = 1)
writeRaster(rc_vs, paste0("rc_vs.tif"), format = "GTiff")

# Antes de ler a tabela dos dados é necessário alterar os nomes da coluna, pois 
# elas ficam deslocadas. A primeira aparece sem nome
# Salva os pontos gerados como uma tabela
write.table(specie, "vs_pontos.csv", row.names = T, sep = ";")

#Transforma em spatial points 
specie = SpatialPoints(specie, proj4string=CRS("+proj=longlat +datum=WGS84")) 
ANTcoor.df <- SpatialPointsDataFrame(specie, data.frame(id=1:length(specie))) 

#Salva em shapefile 
writeOGR(ANTcoor.df, getwd(), 'especie_virtual', 'ESRI Shapefile') 




