
### ---------------------------------------------------------------------
### Gerando Nicho Ecológico para espécie virtual
### ---------------------------------------------------------------------

### ---------------------------------------------------------------------
### Tutorial adaptado de:
### https://cran.r-project.org/web/packages/sdmvspecies/vignettes/sdmvspecies.pdf
### ---------------------------------------------------------------------


# Instalação do pacote SDMVSpecies
# Já está instalado, não precisa ser rodado.
# install.packages("sdmvspecies")

# Dependências instaladas pelo pacote SDMVSpecies
# package mnormt successfully unpacked and MD5 sums checked
# package psych successfully unpacked and MD5 sums checked
# package sdmvspecies successfully unpacked and MD5 sums checked

# The downloaded binary packages are in
# C:\Users\Ricardo Avancini\AppData\Local\Temp\RtmpkV92bD\downloaded_packages


### Alterar o diretório raiz para as variáveis ambientais e não as novas 
### que são formadas pelo eixo da PCA


# Selecionando o diretório raiz
setwd("C:/Users/Ricardo/Documents/Mestrado_IME/dados/worldclim_1_4_30s")
getwd() 
# Exemplo do Tutorial
library("sdmvspecies")
library("raster")

# Listando os arquivos tif
package.dir <- system.file(package="sdmvspecies")
env.dir <- paste(package.dir, "/external/env", sep="")
files <- list.files(pattern=".tif")
env.stack <- raster::stack(files)
print(files)


# carregar os arquivos .tif 
# (Pega apenas os 9 rasters que selecionei com os maiores contribuições na PCA)
# BIO4 = Sazonalidade da temperatura (desvio padrao deviation *100)
# BIO6 = Temperatura minima do mes mais frio
# BIO11 = Temperatura media do trimestre mais frio
# BIO12 = Precipitacao anual
# BIO13 = Precipitacao do mes mais chuvoso
# BIO14 = Precipitacao do mes mais seco
# BIO16 = Precipitacao do trimestre mais chuvoso
# BIO17 = Precipitacao do trimestre mais seco
# BIO19 = Precipitacao do trimestre mais frio

#predictors <- stack(files[c(4, 6, 11, 12, 13, 14, 16, 17, 19)])
# Seleção de apenas 5 das 9 variáveis para gerar a espécie virtual
predictors <- stack(files[c(4, 6, 11, 13, 19)])
names(predictors)
plot(predictors)

# Configurando a função para gerar o nicho da espécie virtual
config <- list(c("bio_04", "1", 1), c("bio_06", "1", 2), c("bio_11", "1", 2), 
               c("bio_01", "1", 1), c("bio_01", "1", 1))
species.raster <- nicheSynthese(env.stack, config)
species.raster <- rescale(species.raster)
plot(species.raster>0.9)

setwd("../..")
getwd()
dir.create("especie_virtual")
setwd("especie_virtual")
getwd()
writeRaster(species.raster, paste0("vs.tif"), format = "GTiff")



