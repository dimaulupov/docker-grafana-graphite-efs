#!/usr/bin/env bash

set -ex

if [ "${EFS_FS_ID}" == "" ] ; then
    echo "Set EFS_FS_ID to efs files system id to use and run this container in privileged mode"
    exit 1
fi

REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F\" '/region/ {print $4}'`
mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${EFS_FS_ID}.efs.${REGION}.amazonaws.com:/ /efs

cd /efs

for p in opt-graphite-storage-whisper var-lib-elasticsearch opt-grafana-data opt-graphite-storage-log var-log var-log/supervisor var-log/nginx var-log/apt var-log/fsck var-log/unattended-upgrades var-log/upstart var-log/elasticsearch ; do
    mkdir -p ${p}
    chmod 777 ${p}
done

/usr/bin/supervisord
