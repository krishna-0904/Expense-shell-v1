#/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="depops.online"
hosted_zone_id="Z016676720U1BMLPXGC61"

for instance in $@
do
    echo "creating instance: $instance"
done