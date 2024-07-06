# Puppet manifest to install and configure Nginx on the server

# Ensure the package is installed
package { 'nginx':
  ensure => installed,
}

# Ensure Nginx service is running and enabled
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}

# Configure Nginx
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
	try_files \$uri \$uri/ =404;
        #return 200 'Hello World!';
    }

    location /redirect_me {
        return 301 https://www.google.com;
    }


    error_page 404 /custom_404.html;
    location = /custom_404.html {
        root /var/www/html;
        internal;
    }

}
  ",
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Create a symlink to enable the site
file { '/etc/nginx/sites-enabled/default':
  ensure  => 'link',
  target  => '/etc/nginx/sites-available/default',
  require => File['/etc/nginx/sites-available/default'],
  notify  => Service['nginx'],
}

# Ensure the default HTML file contains "Hello World!"
file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}
