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
class mutual_trust {}
