# Utilizar la imagen oficial de WordPress con Apache como base
FROM wordpress:latest

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Establecer el modo no interactivo para evitar prompts durante apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Variables de entorno para la base de datos
ENV WORDPRESS_DB_HOST="10.79.208.3"
ENV WORDPRESS_DB_USER="wordpress"
ENV WORDPRESS_DB_PASSWORD="idgleb123"
ENV WORDPRESS_DB_NAME="wordpress"

# Instalar cualquier dependencia adicional necesaria
RUN apt-get update && apt-get install -y \
    vim \
    less \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Establecer permisos adecuados para el directorio de WordPress
RUN chown -R www-data:www-data /var/www/html

# Exponer el puerto 80 para acceso HTTP
EXPOSE 80

# Comando para iniciar Apache en primer plano
CMD ["apache2-foreground"]
