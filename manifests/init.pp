# == Class: mutual_trust
#
# Provides a defined type named "mutual_trust::ssh" which enables mutual
# trust between users on different systems.
#
# All uses of mutual_trust::ssh with the same tag will result in trust to every
# other usage of mutual_trust::ssh with that same tag!
#
# === Parameters
#
#
# [*tag*]
#   Optional (defaults to $name).
#   The tag used to collect resources. All nodes declared with the same tag
#   will trust each other.
#
# [*user*]
#   Optional (defaults to "root").
#   The user for whom to collect public ssh keys.
#
# [*homedir*]
#   Optional (defaults to a guess such as /root or /home/$user)
#   The home directory for the user. This is only used to guess the [*sshdir*]
#   parameter.
#
# [*sshdir*]
#   Optional (defaults to "$homedir/.ssh")
#   The ssh directory containing the authorized_keys file.
#
# === Examples
#
#  include mutual_trust
#  node /foo/ {
#      mutual_trust::ssh {"web":}
#  }
#  node /bar/ {
#      mutual_trust::ssh {"web":}
#      mutual_trust::ssh {"db":}
#  }
#  node /baz/ {
#      mutual_trust::ssh {"db":
#          user => oracle
#      }
#  }
#
#  As a reult, root@foo and root@bar will be able to login to each other.
#  root@bar can also login to oracle@baz and vice versa.
#  oracle@baz cannot login directly to root@foo, but can do so anyway
#  while logged into root@bar.
#
# === Authors
#
# Maarten Thibaut <mthibaut@cisco.com>
#
# === Copyright
#
# Copyright 2012 Maarten Thibaut. Distributed under the Apache License,
# Version 2.0.
#
class mutual_trust {

define ssh(
	$tag     = $name,
	$user    = "root",
	$homedir = undef,
	$sshdir  = undef
) {
	$defaulthome = $user ? {
		/^root$/ => $kernel ? {
			"Solaris"	=> "/",
			default		=> "/root",
		},
		default  => "/home/$user",
	}

	$myhome = $homedir ? {
		/.+/    => $homedir,
		default => $defaulthome
	}
	$myssh = $sshdir ? {
		/.+/    => $sshdir,
		default => "$myhome/.ssh",
	}
			
	file { "$myssh":
		ensure => directory;
	}

	exec { "create_sshkey":
		command => "ssh-keygen -q -N '' -t rsa -f $myssh/id_rsa",
		path    => "/usr/bin:/bin",
		creates => "$myssh/id_rsa.pub",
		require => File["$myssh"],
	}

	if $rootdsakey {
		@@ssh_authorized_key {
		"root-dsa@$hostname":
			ensure => present,
			key    => "$rootdsakey",
			type   => "dsa",
			user   => "root",
			tag    => "$tag",
		}
	}
	if $rootrsakey {
		@@ssh_authorized_key {
		"root-rsa@$hostname":
			ensure => present,
			key    => "$rootrsakey",
			type   => "rsa",
			user   => "root",
			tag    => "$tag",
		}
	}
	Ssh_authorized_key <<| tag == "$tag" |>>
	if $sshdsakey {
		@@sshkey {
		"$hostname-dsa":
			ensure => present,
			host_aliases => [ $hostname, $fqdn, $ipaddress_eth0 ],
			key    => $sshdsakey,
			name   => "$hostname-dsa",
			type   => "dsa",
			tag    => "$tag",
		}
	}
	if $sshrsakey {
		@@sshkey {
		"$hostname-rsa":
			ensure => present,
			host_aliases => [ $hostname, $fqdn, $ipaddress_eth0 ],
			key    => $sshrsakey,
			name   => "$hostname-rsa",
			type   => "rsa",
			tag    => "$tag",
		}
	}
	Sshkey <<| tag == "$tag" |>>
}
}
