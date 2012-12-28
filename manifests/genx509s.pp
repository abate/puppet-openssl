/*

== Class: openssl::genx509s

Only install a single script.
This class is required by openssl::certificate::x509s definition

*/
class openssl::genx509s {
  file {"/usr/local/sbin/generate-x509s-cert.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 0755,
    source => "puppet:///modules/openssl/generate-x509s-cert.sh",
  }
}

class openssl::copyx509s {
  define client ($cert,$ca_dir,$base_dir,$owner) {
    file { $base_dir :
      ensure => directory,
      owner  => root,
    }

    file { "$base_dir/$cert.key" :
      ensure => present,
      owner  => "$owner",
      mode   => 0600,
      content => file("$ca_dir/$cert.key"),
    }

    file { "$base_dir/$cert.cert" :
      ensure => present,
      owner  => "$owner",
      mode   => 0600,
      content => file("$ca_dir/$cert.cert"),
    }
  }
}
