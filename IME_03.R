
### ---------------------------------------------------------------------
### Gerando Nicho Ecol?gico para esp?cie virtual
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

# Selecionando o diretório raiz
setwd("C:/Users/Ricardo Avancini/Documents/SDM_Elith_2017/analise_selecao_variaveis/pca")
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


# carregar os arquivos .tif (Pega apenas os 5 rasters, pois os outros s?o gr?ficos)
predictors <- stack(files[1:5])
names(predictors)
plot(predictors)

# Configurando a fun??o para gerar o nicho da esp?cie virtual
config <- list(c("pc1","1", 1), c("pc2", "1", 1), c("pc3", "1", -2), c("pc4", "1", 1), c("pc5", "1", 1))
species.raster <- nicheSynthese(env.stack, config)
species.raster <- rescale(species.raster)
plot(species.raster>0.7)

setwd("../..")
getwd()
dir.create("especie_virtual")
setwd("especie_virtual")
getwd()
writeRaster(species.raster, paste0("vs.tif"), format = "GTiff")



