define mutual_trust::ssh(
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
