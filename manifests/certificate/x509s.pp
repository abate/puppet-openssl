/*

== Definition: openssl::certificate::x509s

Creates a certificate, key and CSR according to datas provided.
This certificate is signed by the provided CA.

Requires:
- Class["openssl::genx509s"]

Parameters:
- *$ensure*:       ensure wether certif and its config are present or not
- *$country*:      certificate countryName
- *$state*:        certificate stateOrProvinceName
- *$locality*:     certificate localityName
- *$commonname*:   certificate CommonName
- *$altnames*:     certificate subjectAltName. Can be an array or a single string.
- *$organisation*: certificate organizationName
- *$unit*:         certificate organizationalUnitName
- *$email*:        certificate emailAddress
- *$days*:         certificate validity
- *$base_dir*:     where cnf, crt, csr and key should be placed. Directory must exist
- *$cadir*:
- *$ca*:

Example:
node "foo.bar" {
  include openssl::genx509s
  openssl::certificate::x509s {"foo.bar":
    ensure       => present,
    country      => "CH",
    organisation => "Example.com",
    commonname   => $fqdn,
    base_dir     => "/var/www/ssl",
    ca           => "bazCA",
    ca_dir       => "/etc/sslCA",
    password     => "/root/.capwd",
  }
}

This will create files "foo.bar.cnf", "foo.bar.crt", "foo.bar.key" and "foo.bar.csr" in /var/www/ssl/.
All files will belong to user "www-data".

Those files can be used as is for apache, openldap and so on.

*/
define openssl::certificate::x509s($ensure=present,
  $country,
  $state=false,
  $locality=false,
  $organisation,
  $commonname,
  $unit=false,
  $altnames=false,
  $email=false,
  $days=365,
  $base_dir='/etc/ssl/localcerts',
  $ca="ca",
  $ca_dir="/etc/sslCA",
  $password,
  ) {

  file {"${base_dir}":
    ensure  => directory,
    owner   => root,
  }

  file {"${base_dir}/${name}.cnf":
    ensure  => present,
    owner   => root,
    content => template("openssl/cert.cnf.erb"),
  }

  case $ensure {
    'present': {
      File["${base_dir}/${name}.cnf"] {
        notify => Exec["create ${name} certificate"],
      }

      exec {"create ${name} certificate":
        creates => ["${base_dir}/${name}.req", "${base_dir}/${name}.key", "${base_dir}/${name}.cert"],
        user    => root,
        command => "/usr/local/sbin/generate-x509s-cert.sh ${name} ${base_dir}/${name}.cnf ${base_dir}/ ${days} $password",
        require => [File["${base_dir}/${name}.cnf"], Class['openssl::genx509s']],
      }
    }

    'absent':{
      file {[
        "${base_dir}/${name}.req",
        "${base_dir}/${name}.csr",
        "${base_dir}/${name}.cert",
        "${base_dir}/${name}.key",
        ]:
        ensure => absent,
      }
    }

    default: { fail "Unknown \$ensure value: ${ensure}"}
  }
}
