
### ---------------------------------------------------------------------
### Gerando Modelo com o MaxEnt para todas as espécies geradas e 
### salvando os valores de performance dos modelos em uma planilha
### ---------------------------------------------------------------------


### ---------------------------------------------------------------------
### Adaptação do tutorial: https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf
### ---------------------------------------------------------------------

# Instalação do pacote rJava
# Para funcionar depende da instalação do Java no computador (JDK)
#install.packages("rJava")

# Carrega os pacote necessários
library(sp)
library(Rcpp)
library(raster)
library(rgdal)
library(dismo)
library(rJava)
library(maptools)
data(wrld_simpl)

# Selecionando o diretório raiz
setwd("C:/Users/Ricardo/Documents/Mestrado_IME/dados/worldclim_1_4_30s")
getwd() 


# Carregando e preparando os dados
files <- list.files(pattern=".tif")
env.stack <- raster::stack(files)
print(files)

# Selecionando apenas as 13 variáveis preditoras selecionadas na PCA
# BIO1 = Temperatura media anual
# BIO4 = Sazonalidade da temperatura (desvio padrao deviation *100)
# BIO6 = Temperatura minima do mes mais frio
# BIO8 = Temperatura media do trimestre mais chuvoso
# BIO9 = Temperatura media do trimestre mais seco
# BIO11 = Temperatura media do trimestre mais frio
# BIO12 = Precipitacao anual
# BIO13 = Precipitacao do mes mais chuvoso
# BIO14 = Precipitacao do mes mais seco
# BIO15 = Sazonalidade da precipitacao (coeficiente de variacao)
# BIO16 = Precipitacao do trimestre mais chuvoso
# BIO17 = Precipitacao do trimestre mais seco
# BIO19 = Precipitacao do trimestre mais frio


predictors <- stack(files[c(1, 4, 6, 8, 9, 11, 12, 13, 14, 15, 16, 17, 19)])
names(predictors)
plot(predictors)

# Selecionando a pasta da espécie virtual
setwd("../../especie_virtual")
getwd() 

# Carrega o shapefile da espécie virtual sem erro
especie_virtual=readOGR("especie_virtual.shp",layer="especie_virtual")


# Modificação do tutorial para o exemplo da documentação do pacote dismo
# https://cran.r-project.org/web/packages/dismo/dismo.pdf

# file with presence points
occurence <- especie_virtual
occ <- occurence
# witholding a 20% sample for testing
fold <- kfold(occ, k=5)
occtest <- occ[fold == 1, ]
occtrain <- occ[fold != 1, ]
# fit model, biome is a categorical variable (coloquei como null, verificar se posso colocar o raster do rj como máscara)
me <- maxent(predictors, occtrain, factors=NULL)
# see the maxent results in a browser:
# me
# use "args"
# me2 <- maxent(predictors, occtrain, factors='biome', args=c("-J", "-P"))

# plot showing importance of each variable
plot(me)
# response curves
# response(me)
# predict to entire dataset
r <- predict(me, predictors)
# with some options:
# r <- predict(me, predictors, args=c("outputformat=raw"), progress='text',
# filename='maxent_prediction.grd')
plot(r)
points(occ)
#testing
# background data
bg <- randomPoints(predictors, 1000)
#simplest way to use 'evaluate'
e1 <- evaluate(me, p=occtest, a=bg, x=predictors)
# alternative 1
# extract values
pvtest <- data.frame(extract(predictors, occtest))
avtest <- data.frame(extract(predictors, bg))
e2 <- evaluate(me, p=pvtest, a=avtest)
# alternative 2
# predict to testing points
testp <- predict(me, pvtest)
head(testp)
testa <- predict(me, avtest)
e3 <- evaluate(p=testp, a=testa)
e3
threshold(e3)
plot(e3, 'ROC')
  
# Salvando o resultado da modelagem como MaxEnt sem erros de georreferenciamento
writeRaster(r, paste0("maxent_real.tif"), format = "GTiff")






# Loop para fazer um modelo para cada shapefile gerado
# Selecionando o diretório raiz
setwd("./erros_10")
getwd() 


# Carregando e preparando os dados
files <- list.files(pattern=".shp")
print(files)

for(a in 1:length(files)){
  
  # Carrega o shapefile da espécie virtual para cada erro gerado na classe
  nome_layer = gsub(".shp", "", files[a])
  occurence = readOGR(files[a],layer=nome_layer)
  
  occ <- occurence
  # witholding a 20% sample for testing
  fold <- kfold(occ, k=5)
  occtest <- occ[fold == 1, ]
  occtrain <- occ[fold != 1, ]
  # fit model, biome is a categorical variable (coloquei como null, verificar se posso colocar o raster do rj como máscara)
  me <- maxent(predictors, occtrain, factors=NULL)
  # see the maxent results in a browser:
  # me
  # use "args"
  # me2 <- maxent(predictors, occtrain, factors='biome', args=c("-J", "-P"))
  
  # plot showing importance of each variable
  #plot(me)
  # response curves
  # response(me)
  # predict to entire dataset
  r <- predict(me, predictors)
  # with some options:
  # r <- predict(me, predictors, args=c("outputformat=raw"), progress='text',
  # filename='maxent_prediction.grd')
  #plot(r)
  #points(occ)
  #testing
  # background data
  bg <- randomPoints(predictors, 1000)
  #simplest way to use 'evaluate'
  e1 <- evaluate(me, p=occtest, a=bg, x=predictors)
  # alternative 1
  # extract values
  pvtest <- data.frame(extract(predictors, occtest))
  avtest <- data.frame(extract(predictors, bg))
  e2 <- evaluate(me, p=pvtest, a=avtest)
  # alternative 2
  # predict to testing points
  testp <- predict(me, pvtest)
  head(testp)
  testa <- predict(me, avtest)
  e3 <- evaluate(p=testp, a=testa)
  e3
  threshold(e3)
  #plot(e3, 'ROC')
  
  
  nome_raster = paste0("maxent_", nome_layer, ".tif")
  # Salvando o resultado da modelagem como MaxEnt sem erros de georreferenciamento
  writeRaster(r, nome_raster, format = "GTiff")
  
}









