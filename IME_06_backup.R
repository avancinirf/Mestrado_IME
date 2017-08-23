
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

# Selecionando apenas as 9 variáveis preditoras selecionadas na PCA
# BIO4 = Sazonalidade da temperatura (desvio padrao deviation *100)
# BIO6 = Temperatura minima do mes mais frio
# BIO11 = Temperatura media do trimestre mais frio
# BIO12 = Precipitacao anual
# BIO13 = Precipitacao do mes mais chuvoso
# BIO14 = Precipitacao do mes mais seco
# BIO16 = Precipitacao do trimestre mais chuvoso
# BIO17 = Precipitacao do trimestre mais seco
# BIO19 = Precipitacao do trimestre mais frio

# bioma = mascara para todo o estado do rj
bioma <- stack(files[4])
# reclassificando o raster para conter apenas valores 1 ou NA
bioma <- reclassify(bioma, c(minValue(bioma),maxValue(bioma)+1,1))

names(bioma) = "bioma"
predictors <- stack(files[c(4, 6, 11, 12, 13, 14, 16, 17, 19)], bioma)
names(predictors)
plot(predictors)

# Selecionando a pasta da espécie virtual
setwd("../../especie_virtual")
getwd() 

# Carrega o shapefile da espécie virtual sem erro
especie_virtual=readOGR("especie_virtual.shp",layer="especie_virtual")


presvals <- extract(predictors, especie_virtual)
set.seed(0)
backgr <- randomPoints(predictors, 200)
absvals <- extract(predictors, backgr)
pb <- c(rep(1, nrow(presvals)), rep(0, nrow(absvals)))
sdmdata <- data.frame(cbind(pb, rbind(presvals, absvals)))
sdmdata[,'bioma'] = as.factor(sdmdata[,'bioma'])

pred_nf <- dropLayer(predictors, 'bioma')
group <- kfold(especie_virtual, 5)
pres_train <- especie_virtual[group != 1, ]
pres_test <- especie_virtual[group == 1, ]
ext = extent(predictors)
backg <- randomPoints(pred_nf, n=200, ext=ext, extf = 1.25)
colnames(backg) = c('lon', 'lat')
group <- kfold(backg, 5)
backg_train <- backg[group != 1, ]
backg_test <- backg[group == 1, ]
r = raster(pred_nf, 1)
plot(!is.na(r), col=c('white', 'light grey'), legend=FALSE)
plot(ext, add=TRUE, col='red', lwd=2)
points(backg_train, pch='-', cex=0.5, col='yellow')
points(backg_test, pch='-', cex=0.5, col='black')
points(pres_train, pch= '+', col='green')
points(pres_test, pch='+', col='blue')


# checking if the jar file is present. If not, skip this bit
jar <- paste(system.file(package="dismo"), "/java/maxent.jar", sep='')
if (file.exists(jar)) {
  xm <- maxent(predictors, pres_train, factors='bioma')
  plot(xm)
} else { 
  cat('cannot run this example because maxent is not available')
  plot(1)
}

if (file.exists(jar)) {
  response(xm)
} else {
  cat('cannot run this example because maxent is not available')
  plot(1)
}

if (file.exists(jar)) {
  e <- evaluate(pres_test, backg_test, xm, predictors)
  e
  px <- predict(predictors, xm, ext=ext, progress='')
  par(mfrow=c(1,2))
  plot(px, main='Maxent, raw values')
  plot(wrld_simpl, add=TRUE, border='dark grey')
  tr <- threshold(e, 'spec_sens')
  plot(px > tr, main='presence/absence')
  plot(wrld_simpl, add=TRUE, border='dark grey')
  points(pres_train, pch='+')
} else {
  plot(1)
}

# Salvando o resultado da modelagem como MaxEnt sem erros de georreferenciamento
writeRaster(px, paste0("maxent_real.tif"), format = "GTiff")

# Salvando resultados em uma tabela
# Criei apenas um exemplo de como ler o dado.
e@auc
e@presence
e@np
e@prevalence
e@kappa

Refazer usando a documentação do dismo!!!
Conferir e se necessário refazer reclass do bioma corrigindo os valores!!!
  https://cran.r-project.org/web/packages/dismo/dismo.pdf


  predictors <- stack(fnames)
  #plot(predictors)
  # file with presence points
  occurence <- especie_virtual
  occ <- occurence
  # witholding a 20% sample for testing
  fold <- kfold(occ, k=5)
  occtest <- occ[fold == 1, ]
  occtrain <- occ[fold != 1, ]
  # fit model, biome is a categorical variable
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
  }
