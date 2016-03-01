#!/bin/sh
set -e

if [ -z "$MANTL_PROVIDER" ]; then
	echo "mantl.readthedocs.org for provider"
	exit 1
fi

# prompt for SSH if not found
mkdir -p $(dirname $SSH_KEY)
if [ ! -f "$SSH_KEY" ]; then
	ssh-keygen -N '' -f $SSH_KEY
	cp $SSH_KEY* $MANTL_CONFIG_DIR/
else
	cp $MANTL_CONFIG_DIR/$(basename $SSH_KEY) $(dirname $SSH_KEY)
fi

eval $(ssh-agent) && ssh-add $SSH_KEY

# gen security.yml if not found
if [ ! -f $MANTL_CONFIG_DIR/security.yml ]; then
	./security-setup --enable=false
	cp security.yml $MANTL_CONFIG_DIR/security.yml
else
	cp /local/security.yml security.yml
fi

# copy sample.yml to mantl.yml if not found
if [ ! -f $MANTL_CONFIG_DIR/mantl.yml ]; then
	cp sample.yml mantl.yml
	cp sample.yml $MANTL_CONFIG_DIR/mantl.yml
else
	cp $MANTL_CONFIG_DIR/mantl.yml mantl.yml
fi

# copy terraform sample file based on MANTL_PROVIDER env if user one doesn't exist
if [ "$(find $MANTL_CONFIG_DIR -name '*.tf')" == "" ]; then
	cp /mantl/terraform/"$MANTL_PROVIDER".sample.tf mantl.tf
	cp /mantl/terraform/"$MANTL_PROVIDER".sample.tf $MANTL_CONFIG_DIR/mantl.tf
else
	cp /local/*.tf /mantl/
fi

terraform get
terraform apply
ansible-playbook /mantl/playbooks/wait-for-hosts.yml --private-key $SSH_KEY
ansible-playbook mantl.yml -e @"$MANTL_CONFIG_DIR/security.yml" --private-key $SSH_KEY
