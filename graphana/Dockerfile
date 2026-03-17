FROM php:8.1-apache

# Install driver supaya PHP boleh cakap dengan MySQL/MariaDB
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Enable mod_rewrite (kot2 perlu nanti)
RUN a2enmod rewrite
