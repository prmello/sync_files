# sync_files
Shell script for sync files between linux servers in a active/passive cluster environment.

# Requiriments
- Rsync 3 or later

This script don't use password authentication, please configure the keys on know_hosts in the servers.


# Usage
Place all files in:
```shell
/usr/local/sbin/
```

Edit sync_files.par to include the directories for replication, without / in front of. Content example:
```shell
example/example
example1/example
example/example1
```

Follow the same steps for sync_file_exclude.par, for exclude directories from the replication

For run the script, use:
```shell
./sync_files.sh <active_node_cluster_ip>
```
Example:
```shell
./sync_files.sh 192.168.1.1
```

# Authors
This script are developed by Paulo Ricardo de Mello and Anderson Arthur Nuss.

# Contact
E-mail: paulo.mello@outlook.com
