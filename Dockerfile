# Stage 1: Build Node.js application
FROM node:16.17.0-bullseye-slim as node-builder

# Set the working directory
WORKDIR /app

# Copy application code
COPY . .

# Install Node.js dependencies and build frontend assets
RUN npm install && npm run build

# Stage 2: Install PHP and Laravel dependencies
FROM php:8.2-apache as php-builder

# Set the working directory
WORKDIR /app

# Copy application code
COPY . .
#COPY .env  .env
# Install PHP extensions and Composer
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    libzip-dev unzip zlib1g-dev libpng-dev libonig-dev libxml2-dev && \
    docker-php-ext-install zip pdo pdo_mysql mbstring && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install --no-dev --optimize-autoloader --no-interaction && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: Apache with SSL and Proxy modules
FROM httpd:latest as apache-setup

# Install required packages for Apache
RUN apt-get update && apt-get install -y --no-install-recommends openssl && \
    rm -rf /var/lib/apt/lists/*

# Enable necessary Apache modules
RUN sed -i \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/#LoadModule ssl_module/LoadModule ssl_module/' \
    -e 's/#LoadModule socache_shmcb_module/LoadModule socache_shmcb_module/' \
    -e 's/#LoadModule proxy_module/LoadModule proxy_module/' \
    -e 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' \
    /usr/local/apache2/conf/httpd.conf

# Copy Apache configuration
COPY apache-conf/httpd.conf /usr/local/apache2/conf/httpd.conf

# Copy the built files from Node.js builder stage
COPY --from=node-builder /app/public /usr/local/apache2/htdocs

# Expose necessary ports
EXPOSE 80 443

# Run Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]
