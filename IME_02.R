


### ---------------------------------------------------------------------
### Selecionando as variáveis preditoras com Correlação, PCA e fatorial
### ---------------------------------------------------------------------

### ---------------------------------------------------------------------
### Tutorial adaptado de:
### www.leec.eco.br/downloads/apostila_r_nicho_vancine_2016.pdf
### ---------------------------------------------------------------------


# Instalação dos pacotes necessários c("raster", "rgdal", "corrplot", "RStoolbox", "vegan", "psych")
# install.packages(c("corrplot", "RStoolbox", "vegan", "psych"), dep = T)

library("corrplot")
library("RStoolbox")
library("vegan")
library("psych")




### ---------------------------------------------------------------------
### Preparação dos dados
### ---------------------------------------------------------------------


### ---------------------------------------------------------------------
# Capítulo: 2.2 Preparação dos dados
# Resumo: O Tutorial original realiza as análises com dados no formato asc.
# No tutorial original as variáveis preditoras são denominadas como "as", 
# eu alterei para "predictors"
#
#
### ---------------------------------------------------------------------

# diretorio aonde estão as variáveis ambientais (tif)
setwd("C:/Users/Ricardo/Documents/Mestrado_IME/dados/worldclim_1_4_30s")
# listar o nome dos arquivos no diretorio com o padrao .asc
tif <- list.files(pattern = ".tif")
tif

# carregar os arquivos .tif
predictors <- stack(tif)
predictors
names(predictors)

# renomear as variaveis (Não foi necessário)
#names(predictors)
#names(predictors) <- paste0("bio", 01:19)
#names(predictors)
#predictors

# plot
plot(predictors)
plot(predictors[[1]])
# extraindo valores dos arquivos .tif e omitindo os NAs
predictors.v <- values(predictors)
predictors.v.na <- na.omit(predictors.v)
head(predictors.v.na)
dim(predictors.v.na)


# Altera a pasta do diretório default do projeto
setwd("C:/Users/Ricardo/Documents/Mestrado_IME")

# criar pasta e definir diretorio para analise exploratoria - correlacao
# cria uma pasta no diretorio
dir.create("analise_selecao_variaveis")
# muda o diretorio para a pasta criada
setwd("./analise_selecao_variaveis")



### ---------------------------------------------------------------------
### Correlação
### ---------------------------------------------------------------------


### ---------------------------------------------------------------------
# Capítulo: 2.3 Correlação
# Resumo: Correlação de Pearson para as 19 variáveis bioclimáticas
# A correlação é uma das análises mais simples em qualquer análise estatística descritiva. Nesse
# exemplo, usaremos a correlação de Pearson para as 19 variáveis bioclimáticas. O valor do coeficiente de
# correlação de Pearson (ρ ou r) mede a relação entre duas variáveis e varia de -1 (negativamente
# correlacionadas), 0 (sem correlação) e 1 (positivamente correlacionas). O resultado da análise será uma
# matriz “triangulas” (valores iguais acima e abaixo da diagonal da matriz), relacionando nas linhas e nas
# colunas as 19 variáveis bioclimáticas.
# Geralmente assume-se correlação entre duas variáveis, se as mesmas possuem ρ ou r acima de
# 0.7 ou abaixo de -0.7. No entanto, isso não é uma regra e outros valores, acima ou abaixo desse limiar
# podem ser escolhidos, dependendo da pergunta que se tem a responder.
### ---------------------------------------------------------------------

# cria uma pasta no diretorio
dir.create("correlacao")
# muda o diretorio para a pasta criada
setwd("./correlacao") 

# Confere o caminho do diretório default do projeto
getwd() 


# tabela da correlacao
cor <- cor(predictors.v.na)
cor
# arredondamento dos valores para dois valores decimais
round(cor, 2) 


# exportar tabela com a correlacao
write.table(round(cor(predictors.v.na), 2), "cor_pres.xls", row.names = T, sep = "\t")
write.table(round(cor(predictors.v.na), 2), "cor_pres.csv", row.names = T, sep = ";")

# Definindo valor de corte para correlação como 0.7 e colocando resultado na tabela
write.table(ifelse(cor(predictors.v.na) >= 0.7, "Sim", "Não"), "cor_pres_afirmacao.xls", row.names = T, sep = "\t")
write.table(ifelse(cor(predictors.v.na) >= 0.7, "Sim", "Não"), "cor_pres_afirmacao.csv", row.names = T, sep = ";")

# Plot da correlacao (Gera uma imagem)
tiff("cor_ma.tif", width = 18, height = 18, units = "cm", res = 300, compression = "lzw")
corrplot(cor(predictors.v.na), type = "lower", diag = F, tl.srt = 45, mar = c(3, 0.5, 2, 1), title = "Correlações entre variáveis Bioclimáticas")
dev.off()



### ---------------------------------------------------------------------
### Análise de Componentes Principais (PCA)
### ---------------------------------------------------------------------


### ---------------------------------------------------------------------
# Capítulo: 2.4 Análise de Componentes Principais (PCA)
# Resumo: Análise de Componentes Principais (PCA) para as 19 variáveis bioclimáticas
# Essa análise tem como objetivo reduzir o número de variáveis, uma vez
# que as novas variáveis criadas a partir das variáveis originais são ortogonais (relacionam-se a 90°, i.e.,
# são independentes) e ordenar as linhas (observações) de uma matriz a partir das colunas (descritores).
# Há duas formar de fazer uso da PCA: 1. selecionar uma variável bioclimática original para cada
# eixo da PCA, que possuam alta contribuição para cada eixo da PCA; e 2. utilizar os próprios eixos da
# PCA como novas variáveis independentes, utilizando aquelas que tenham contribuição relativa também
# alta. Ambas as formas possuem vantagens e desvantagens e cabe ao pesquisador escolher, com base na
# pergunta que se quer responder com o uso do ENM, a melhor forma de utilizar esse método.
### ---------------------------------------------------------------------

# criar pasta e definir diretorio para analise exploratoria - pca
# voltar uma pasta no diretorio
setwd("..")
# conferir o diretorio
getwd()
# criar pasta no diretorio
dir.create("pca")
# mudar o diretorio para a pasta criada
setwd("./pca")
# conferir o diretorio
getwd()

names(predictors)
# pca do pacote "stats"
# pca com normalizacao interna
pca <- prcomp(predictors.v.na, scale = T)
# contribuicao de cada eixo (eigenvalues - autovalores)
summary(pca)
# grafico de barras com as contribuicoes
screeplot(pca, main = "Contribuição de cada PC", ylab = "Autovalores")
abline(h = 1, col = "red", lty = 2)
tiff("screeplot.tif", width = 18, height = 18, units = "cm", res = 300, compression = "lzw")
screeplot(pca, main = "Contribuição de cada PC", ylab = "Autovalores")
abline(h = 1, col = "red", lty = 2)
dev.off()

# valores de cada eixo (eigenvectors - autovetores - escores)
pca$x

# Apenas para 5 variáveis ambientais (Caso seja necessário exibir apenas parte dos dados)
# relacao das variaveis com cada eixo (loadings - cargas)
pca$rotation[, 1:5]
abs(pca$rotation[, 1:5])

# exportar tabela com a contribuicao
write.table(round(abs(pca$rotation[, 1:5]), 2), "contr_pca.xls", row.names = T, sep = "\t")
# plot
biplot(pca)

# Para todos as 19 variáveis ambientais
# relacao das variaveis com cada eixo (loadings - cargas)
#pca$rotation
#abs(pca$rotation)

# exportar tabela com a contribuicao
#write.table(round(abs(pca$rotation), 2), "contr_pca.xls", row.names = T, sep = "\t")

# plot
#biplot(pca)



# pca como novas variaveis
# pca dos raster
pca.as <- rasterPCA(predictors, spca = T) # esse comando ira demorar
pca.as
# contribuicao dos componentes
summary(pca.as$model)
# grafico de barras com as contribuicoes
screeplot(pca.as$model, main = "Autovalores")
abline(h = 1, col = "red", lty = 2)
tiff("screeplot_raster.tif", width = 20, height = 20, units = "cm", res = 300, compression = "lzw")
screeplot(pca.as$model, main = "Autovalores")
abline(h = 1, col = "red", lty = 2)
dev.off()
# plot das pcs como novas variaveis
plot(pca.as$map[[1:5]])

# exportar as novas variaveis (Eixo da PCA)
# Esse comando gerou 5 imagens asc.
for(i in 1:5){
  # O formato original era ".asc", alterei para ".tif"
  #writeRaster(pca.as$map[[i]], paste0("pc", i, ".asc"), format = "ascii")
  writeRaster(pca.as$map[[i]], paste0("pc", i, ".tif"), format = "GTiff")
}







### ---------------------------------------------------------------------
### Análise Fatorial
### ---------------------------------------------------------------------


### ---------------------------------------------------------------------
# Capítulo: 2.5 Análise Fatorial
# Resumo: Análise Fatorial para as 19 variáveis bioclimáticas
# A análise fatorial é muito parecida com a PCA, sendo que o objetivo também é selecionar as
# variáveis pela contribuição de cada variável a cada eixo da fatorial. No entanto, a diferença é que
# podemos escolher o número de eixos que queremos que as variáveis tenham relação com cada eixo da
# fatorial, aumentando assim essa relação.
# O resultado é uma matriz que relaciona cada variável a cada eixo, sendo que os valores, com esse
# tipo de variável ambiental, irão variar de -1 a 1. Da mesma forma que na correlação de Pearson,
# escolhemos os maiores valores absolutos, um para cada eixo, levando em consideração a biologia da
# espécie.
# Essa análise, com esse propósito, foi proposta no trabalho do Prof. Thadeu (Sobral-Souza, LimaRibeiro & Solferini 2015).
### ---------------------------------------------------------------------

# criar pasta e definir diretorio para analise exploratoria - fatorial
setwd("..")
getwd()
dir.create("fatorial")
setwd("./fatorial")
getwd() 


# padronizacao dos dados
predictors.v.na.p <- decostand(predictors.v.na, method = "standardize")
summary(predictors.v.na.p)

# analises preliminares de possibilidade de uso da analise fatorial
# kmo e bartlett
KMO(cor(predictors.v.na.p)) # deve ser acima de 0.5
cortest.bartlett(cor(predictors.v.na.p), n = nrow(predictors.v.na)) # deve ser sognificativo (p < 0.05)

# numero de eixos - semelhante a pca
# screeplot
fa <- fa.parallel(predictors.v.na.p, fm = "ml", fa = "fa") # sugere 5 eixos
























