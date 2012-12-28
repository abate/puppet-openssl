puppet-openssl
==============

CA infrastructure
=============

On the host acting as CA we create the ca and then we create and sign all needed certificates.

  # we create the CA
  include openssl::genca
  openssl::certificate::ca {"myca":
    ensure       => present,
    country      => "FR",
    state        => "Île-de-France",
    locality     => "Paris",
    organisation => "MyOrg",
    unit         => "MyUnit",
    commonname   => "myca.org",
    email        => "webmaster@myca.org",
    base_dir     => "/etc/ssl",
    ca_dir       => "/etc/sslCA",
    password     => "/root/.capwd",
  }

  # All certs are created and signed by the CA
  include openssl::genx509s
  openssl::certificate::x509s {"myweb.org":
    ensure       => present,
    organisation => "myOrg",
    country      => "FR",
    state        => "Île-de-France",
    locality     => "Paris",
    unit         => "Web Server",
    commonname   => "*.myweb.org",
    email        => "webmaster@myca.org",
    base_dir     => "/etc/ssl/localcerts",
    ca           => "myca",
    ca_dir       => "/etc/sslCA",
    password     => "/root/.capwd",
  }

On each client we copy the certificates created and signed by the ca

  include openssl::genx509s
  openssl::copyx509s::client { 'client':
    cert      => "myweb.org",
    ca_dir    => "/etc/ssl/localcerts",
    base_dir  => "/etc/ssl/localcerts",
    owner     => "www-data",
  }
