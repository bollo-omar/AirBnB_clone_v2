
#!/usr/bin/env bash
y static
$whisper_dirs = [ '/data/', '/data/web_static/',
                        '/data/web_static/releases/', '/data/web_static/shared/',
                        '/data/web_static/releases/test/'
                  ]

package {'nginx':
  ensure  => installed,
}

file { $whisper_dirs:
        ensure  => 'directory',
        owner   => 'ubuntu',
        group   => 'ubuntu',
        recurse => 'remote',
        mode    => '0777',
}
file { '/data/web_static/current':
  ensure => link,
  target => '/data/web_static/releases/test/',
}
file {'/data/web_static/releases/test/index.html':
  ensure  => present,
  content => 'Holberton School for the win!',
}

exec { 'chown -R ubuntu:ubuntu /data/':
  path => '/usr/bin/:/usr/local/bin/:/bin/'
}

file_line {'deploy static':
  path  => '/etc/nginx/sites-available/default',
  after => 'server_name _;',
  line  => "\n\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}",
}

service {'nginx':
  ensure  => running,
}

exec {'/etc/init.d/nginx restart':
}
# Sets up a web server for deployment of web_static.

sudo apt-get update
sudo apt-get install nginx

mkdir  /data/web_static/releases/test/
mkdir  /data/web_static/shared/
echo "Holberton School" > /data/web_static/releases/test/index.html
ln -sf /data/web_static/releases/test/ /data/web_static/current

chown -R ubuntu /data/
chgrp -R ubuntu /data/

printf %s "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    add_header X-Served-By $HOSTNAME;
    root   /var/www/html;
    index  index.html index.htm;

    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }

    location /redirect_me {
        return 301 http://cuberule.com/;
    }

    error_page 404 /404.html;
    location /404 {
      root /var/www/html;
      internal;
    }
}" > /etc/nginx/sites-available/default

service nginx restart
