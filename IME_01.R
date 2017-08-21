


### ---------------------------------------------------------------------
### Processando dados WorldClim 1.4 30s
### ---------------------------------------------------------------------

# Resumo: Processamento de das imagens do WorldClim. 
# Recorte das imagens para o Estado do RJ

# Variáveis Ambientais disponíveis e seus significados:
# BIO1 = Temperatura media anual
# BIO2 = Variacao da media diurna (media por mes (temp max - temp min))
# BIO3 = Isotermalidade (BIO2/BIO7) (* 100)
# BIO4 = Sazonalidade da temperatura (desvio padrao deviation *100)
# BIO5 = Temperatura maxima do mes mais quente
# BIO6 = Temperatura minima do mes mais frio
# BIO7 = Variacao da temperatura anual (BIO5-BIO6)
# BIO8 = Temperatura media do trimestre mais chuvoso
# BIO9 = Temperatura media do trimestre mais seco
# BIO10 = Temperatura media do trimestre mais quente
# BIO11 = Temperatura media do trimestre mais frio
# BIO12 = Precipitacao anual
# BIO13 = Precipitacao do mes mais chuvoso
# BIO14 = Precipitacao do mes mais seco
# BIO15 = Sazonalidade da precipitacao (coeficiente de variacao)
# BIO16 = Precipitacao do trimestre mais chuvoso
# BIO17 = Precipitacao do trimestre mais seco
# BIO18 = Precipitacao do trimestre mais quente
# BIO19 = Precipitacao do trimestre mais frio

# Instalação dos pacotes necessários
#install.packages("sp")
#install.packages("Rcpp")
#install.packages("raster")
#install.packages("rgdal")
#install.packages("dismo")
#install.packages("rJava")
#install.packages("rgdal")
#install.packages("maptools")

# Carrega os pacote necessários
library(sp)
library(Rcpp)
library(raster)
library(rgdal)
library(dismo)
library(rJava)
library(rgdal)
library(maptools)
data(wrld_simpl)


### ---------------------------------------------------------------------
### Preparando os dados climáticos e a área de estudo
### ---------------------------------------------------------------------

# Carregando o limite do Estado do RJ
rj <- readOGR("C:/Users/Ricardo/Documents/Mestrado_IME/dados/shapefiles", "estados_rj")

# Pegando as coordenadas limitrofes do Estado do RJ
ext <- bbox(rj)

# Carregando as imagens tiff com os dados do WorldClim 1.4 (30s)
files <- list.files(path="C:/Users/Ricardo/Documents/Mestrado_IME/dados/worldclim_1_4_30s", pattern="*.bil$", full.names=TRUE)
predictors <- stack(files)

# Verifica quantas camadas (layers) existem na pilha de dados
nlayers(predictors)

# Loop para clipar (crop) as variáveis climáticas e salvar em uma nova pasta do projeto
for(i in 1:nlayers(predictors)){
  # Coloca uma camada em uma variável temporária
  rasterTemp = raster(predictors, i)
  # Clipa o tiff para a área do extent (ext) do Estado do RJ
  rasterTempCrop <- crop(rasterTemp,rj)
  rasterTempCrop <- mask(rasterTempCrop,rj)
  # Salva o novo tif em uma pasta com o nome da camada
  url<-paste("Mestrado_IME/dados/worldclim_1_4_30s/",names(rasterTempCrop),".tif",sep='')
  writeRaster(rasterTempCrop, filename=url, format="GTiff", overwrite=TRUE)
}

files <- list.files(path="C:/Users/Ricardo/Documents/Mestrado_IME/dados/worldclim_1_4_30s", pattern=".tif", full.names=TRUE)
predictors <- stack(files)



