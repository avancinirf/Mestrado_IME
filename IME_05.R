
### ---------------------------------------------------------------------
### Gerando Erros Randômicos para espécie virtual
### ---------------------------------------------------------------------

# Carregando as bibliotecas necessárias
library(sp)
library(rgdal)
library(raster)

# Já foi instalado, não precisa instalar novamente
# install.packages("rgeos")
library(rgeos)
library(dismo)

# Selecionando o diretório raiz
setwd("C:/Users/Ricardo/Documents/Mestrado_IME/especie_virtual")
getwd() 

# Cria as pastas para as classes de erro (% de ocorrências que sofrerão erros)
# 10%, 30% e 50%
# Já foram criadas a spastas, remover antes de executar novamente.
# Caso sejam adicionadas novas classes é necessário alterar o código
dir.create("erros_10")
dir.create("erros_30")
dir.create("erros_50")

# seleciona o shapefile original em uma variável
vs <- readOGR(".","especie_virtual")



# Cria os shapefiles com os erros
# Loop para n repetições de erro (n amostral para cada classe de porcentagem)
for(a in 1:3){
  
  ### ------------------------------------------
  ### Erros em 10% dos pontos
  ### ------------------------------------------
  
  # Alterando para a pasta dos erros em 10% dos pontos (5 pontos)
  setwd("erros_10")
  
  ### ------------------------------------------
  ### Erros de 1Km em 10%
  ### ------------------------------------------
  # Passa os pontos para uma nova variável
  vs_10_1km = vs
  # lê as coordenadas do ponto 50
  vs_10_1km@coords[50,1:2]
  
  # Converte a projeção dos pontos
  vs_10_1km <- spTransform(vs_10_1km, CRS("+proj=aea +datum=WGS84 +units=m"))

  # Gera os erros em 10% dos pontos (5 pontos)
  # Seleciona o índice de 5 pontos
  x5 <- sample(1:50, 5, replace=F)

  # Loop para alterar as coordenadas de cada ponto necessário
  for(i in 1:5){
    # Gera um buffer temporário para o ponto
    buffer_temp <- gBuffer(vs_10_1km[x5[i],], width=1000)
    #plot(buffer_temp)
    # Gera um ponto aleatório dentro do buffer
    ponto_temp <- spsample(buffer_temp, n = 1, "random")
    # Sobrescreve as coordenadas do ponto com os erros
    vs_10_1km@coords[x5[i],1] = ponto_temp@coords[1,1]
    vs_10_1km@coords[x5[i],2] = ponto_temp@coords[1,2]
  }
  
  # Converte novamente a projeção dos pontos para geográfico
  vs_10_1km <- spTransform(vs_10_1km, CRS("+proj=longlat +datum=WGS84"))
  
  # Cria o nome do shapefile com o numero do n em que ele foi gerado
  nome_shp = paste0("vs_10_1km_",a)
  
  #Salva em shapefile
  writeOGR(vs_10_1km, getwd(), nome_shp, 'ESRI Shapefile') 
  
  
  
  ### ------------------------------------------
  ### Erros de 5Km em 10%
  ### ------------------------------------------
  # Passa os pontos para uma nova variável
  vs_10_5km = vs
  
  # Converte a projeção dos pontos
  vs_10_5km <- spTransform(vs_10_5km, CRS("+proj=aea +datum=WGS84 +units=m"))
  
  # Loop para alterar as coordenadas de cada ponto necessário
  for(i in 1:5){
    # Gera um buffer temporário para o ponto
    buffer_temp <- gBuffer(vs_10_5km[x5[i],], width=5000)
    # Gera um ponto aleatório dentro do buffer
    ponto_temp <- spsample(buffer_temp, n = 1, "random")
    # Sobrescreve as coordenadas do ponto com os erros
    vs_10_5km@coords[x5[i],1] = ponto_temp@coords[1,1]
    vs_10_5km@coords[x5[i],2] = ponto_temp@coords[1,2]
  }
  
  # Converte novamente a projeção dos pontos para geográfico
  vs_10_5km <- spTransform(vs_10_5km, CRS("+proj=longlat +datum=WGS84"))
  
  # Cria o nome do shapefile com o numero do n em que ele foi gerado
  nome_shp = paste0("vs_10_5km_",a)
  
  #Salva em shapefile
  writeOGR(vs_10_5km, getwd(), nome_shp, 'ESRI Shapefile') 
  

  
  
  
  

  ### ------------------------------------------
  ### Erros em 30% dos pontos
  ### ------------------------------------------
  
  # Alterando para a pasta dos erros em 30% dos pontos (14 pontos)  
  setwd("..")
  setwd("erros_30")
  
  ### ------------------------------------------
  ### Erros de 1Km em 30%
  ### ------------------------------------------
  
  
  # Volta para a pasta raiz dos testes (especie_virtual)
  setwd("..")
  
  

} # End Loop para as n repetições de erros




