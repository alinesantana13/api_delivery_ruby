# Cria uma imagem a partir da imagem oficial do Ruby 3.2.3
FROM registry.docker.com/library/ruby:3.2.3-slim
# Atualiza o instalador de pacotes do Linux
# e instala algumas dependências "básicas" no S.O.
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential git libvips pkg-config curl libsqlite3-0 nodejs
# Cria um diretório na imagem onde vão viver os arquivos
# da aplicação Rails
WORKDIR /delivery
# Copia todos os arquivos (atuais) da aplicação rails para a Imagem
COPY . /delivery
# Instala as dependências (atuais) da aplicação
RUN bundle install
