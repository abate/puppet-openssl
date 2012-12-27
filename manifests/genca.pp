/*

== Class: openssl::genca

Only install a single script.
This class is required by openssl::certificate::ca definition */

class openssl::genca {
  file {"/usr/local/sbin/generate-x509-cacert.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 0755,
    source => "puppet:///modules/openssl/generate-x509-cacert.sh",
  }
}
