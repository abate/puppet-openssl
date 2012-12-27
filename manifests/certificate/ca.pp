/*

== Definition: openssl::certificate::x509

Creates a certificate, key and CSR according to datas provided.

Requires:
- Class["openssl::genx509"]

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
- *$password*:     certificate password file. File must exist
- *$base_dir*:     where .cnf file should be placed. Directory must exist
- *$ca_dir*:       where ca private and public key should be placed. Directory must exist

Example:
node "foo.bar" {
  include openssl::genx509
  openssl::certificate::ca {"foo.bar":
    ensure       => present,
    country      => "CH",
    organisation => "Example.com",
    commonname   => $fqdn,
    base_dir     => "/etc/ssl",
    ca_dir       => "/etc/sslCA",
    password     => "/root/.capwd",
  }
}

This will create files "foo.bar.cnf" in /etc/ssl and 
 "foo.bar.cert" and "private/foo.bar.key" in /etc/sslCA.

All files will belong to user "root".

*/
define openssl::certificate::ca($ensure=present,
  $country,
  $state=false,
  $locality=false,
  $organisation,
  $commonname,
  $unit=false,
  $altnames=false,
  $email=false,
  $days=365,
  $password,
  $base_dir='/etc/ssl',
  $ca_dir='/etc/sslCA',
  $owner='root'
  ) {

  file { "${ca_dir}":
    ensure => directory,
    owner  => $owner,
  }

  file { "${ca_dir}/private":
    ensure => directory,
    owner  => $owner,
  }

  file {"${base_dir}/${name}.cnf":
    ensure  => present,
    owner   => $owner,
    content => template("openssl/cert.cnf.erb"),
  }

  case $ensure {
    'present': {
      File["${base_dir}/${name}.cnf"] {
        notify => Exec["create ${name} certificate"],
      }

      exec {"create ${name} certificate":
        creates => ["${ca_dir}/${name}.cert","${ca_dir}/private/${name}.key"],
        user    => $owner,
        command => "/usr/local/sbin/generate-x509-cacert.sh ${name} ${base_dir}/${name}.cnf ${ca_dir}/ ${days} $password",
        require => [File["${base_dir}/${name}.cnf"], Class['openssl::genca']],
      }
    }

    'absent':{
      file {[
        "${ca_dir}/${name}.cert",
        "${ca_dir}/private/${name}.key",
        "${ca_dir}/private",
        "${ca_dir}",
        ]:
        ensure => absent,
      }
    }

    default: { fail "Unknown \$ensure value: ${ensure}"}
  }
}
