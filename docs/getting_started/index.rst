Getting Started
===============

.. Note:: This document assumes you have a `working Ansible
          installation`_. If you don't, install Ansible before
          continuing. This can be done simply by running ``pip install -r
          requirements.txt`` from the root of the project.

          It also assumes you have a working Terraform installation which you can download from `Terraform downloads`_.

The Mantl project uses Ansible to bring up
nodes and clusters. This generally means that you need three things:

1. hosts to use as the base for your cluster
2. an `inventory file`_ with the hosts you want to be modified. Mantl includes ansible inventory within its `Dynamic inventory for Terraform.py`_.
3. a playbook to show which components should go where. Mantl organizes its components in `sample.yml`_, which we recommend copying to ``mantl.yml``
     for the possibility of later customization. You can read more about `playbooks`_ in the Ansible docs.

Preparing to provision Cloud Hosts
----------------------------------

The playbooks and roles in this project will work on whatever provider
(or metal) you care to spin up, as long as it can run CentOS 7 or
equivalent.

There are several preparatory steps to provisioning the cloud hosts that are common to all providers:

Step 1: SSH and SSL
>>>>>>>>>>>>>>>>>>>>>>>

The first step for provisioning with any platform is `generating ssh-keys`_ and `secure copying`_ both the public and private keys to your host.

   .. code-block:: shell

        ssh-keygen -t rsa -f /path/to/project/sshkey -C "sshkey"
        scp -P port /path/to/project/id_rsa* <user>@<host>:.ssh/

Step 2: Copy .tf file
>>>>>>>>>>>>>>>>>>>>>

You will also need to copy the .tf file of the platform you are using from `mantl/terraform/`_ to the root of the project. For example, ``mantl/terraform/openstack-modules.sample.tf`` will need to be copied to ``mantl/openstack-module-sample.tf``. The variables in the copied .tf file will need to be changed to your configuration.

    .. note:: Greater than one .tf file in existance in the mantl directory will lead to errors upon deployment. If you work with more than one provider, extra .tf files will need to be renamed or moved.

Step 3: Run security-setup script
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

You'll want set up authentication and authorization by running the ``security-setup`` script in the root directory. This will create and set passwords, authentication, and certificates. For more information, see the `security-setup`_ documentation.

Step 4: Set up DNS records
>>>>>>>>>>>>>>>>>>>>>>>>>>

You can set up your DNS records with Terraform: `dns.rst`_

Provisioning Cloud Hosts
------------------------

Here are some guides specific to each of the common platforms that mantl supports:

- `openstack.rst`_
- `gce.rst`_
- `aws.rst`_
- `digitalocean.rst`_
- `vsphere.rst`_
- `softlayer.rst`_

Deploying software via Ansible
------------------------------

.. note:: Ansible requres a Python 2 binary. If yours is not at /usr/bin/python,
          please view the `Ansible FAQ <http://docs.ansible.com/faq.html>`_. You
          can add an extra variable to the following commands, e.g.
          ``ansible -e ansible_python_interpreter=/path/to/python2``.

The following steps assume that you have provisioned your cloud host by taking the steps listed in one of the guides listed above. We're going to assume you deployed hosts using
Terraform (all the way through terraform apply).This project ships with a dynamic inventory file to read Terraform
``.tfstate`` files. If you are running ansible from the root directory of the
project, this inventory file will be used by default. If not, or to use a custom
inventory file, you can use the ``-i`` argument of ``ansible`` or
``ansible-playbook`` to specify the inventory file path. For example:

.. code-block:: shell

   ansible-playbook -i path/to/inventory -e @security.yml mantl.yml

Steps to deploying via ansible:
-------------------------------

Ping the servers to ensure they are reachable via ssh:
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    .. code-block:: shell

        ansible all -m ping

   It may take a few minutes after terraform for the servers to be reachable. If any servers fail to connect, you can check your connection by adding ``-vvvv`` for verbose SSH debugging and try again to view the errors in more detail.

Upgrade packages:
>>>>>>>>>>>>>>>>>

    .. warning::

        Due to updated packages in the recent CentOS-7 (1511) release, it is critical
        that you upgrade operating system packages on all server before proceeding
        with deployment:

    .. code-block:: shell

        ansible-playbook playbooks/upgrade-packages.yml

   If you neglect to upgrade packages, you will likely experience multiple
   failures, particularly around Consul. See issues `907`_ and
   `927`_ for more details.

Deploy the software:
>>>>>>>>>>>>>>>>>>>>

   First, you'll need to customize a playbook. A sample can be found at ``sample.yml`` in the root directory which you can copy to ``mantl.yml``. You can find more about customizing this at `playbooks`_. The main change you'll want to make is changing ``consul_acl_datacenter`` to your preferred ACL datacenter. If you only have one datacenter, you can remove this variable. Next, assuming you've placed the filled-out template at ``mantl.yml``:

    .. code-block:: shell

        ansible-playbook -e @security.yml mantl.yml

    The deployment will probably take a while as all tasks are completed.

Checking your deployment
------------------------

Once your deployment has completed, you will be able to access the Mantl UI
in your browser by connecting to one of the control nodes.

If you need the IP address of your nodes, you can use ``terraform.py``:

.. code-block:: shell

   $ plugins/inventory/terraform.py --hostfile
   ## begin hosts generated by terraform.py ##
   xxx.xxx.xxx.xxx         mantl-control-01
   xxx.xxx.xxx.xxx         mantl-control-02
   xxx.xxx.xxx.xxx         mantl-control-03
   xxx.xxx.xxx.xxx         mantl-edge-01
   xxx.xxx.xxx.xxx         mantl-edge-02
   xxx.xxx.xxx.xxx         mantl-worker-001
   xxx.xxx.xxx.xxx         mantl-worker-002
   xxx.xxx.xxx.xxx         mantl-worker-003
   ## end hosts generated by terraform.py ##

When you enter a control node's IP address into your browser, you'll likely get
prompted about invalid security certificates if you have SSL/TLS turned on.
(Follow your browser's instructions on how to access a site without a valid
cert.) Then, you will be presented with a basic access authentication prompt.
The username and password for this is based upon the ``security.yml`` file that
you generated earlier with the ``security-setup`` script.

Here is what you should be looking at after you connect and authenticate:

.. image:: https://raw.githubusercontent.com/CiscoCloud/nginx-mantlui/master/screenshot.png
     :alt: Screenshot of Mantl UI in action
     :target: https://github.com/CiscoCloud/nginx-mantlui

Click the image to go to the `GitHub project`_

Customizing your deployment
---------------------------

Below are guides customizing your deployment:

- `ssh_users.rst`_
- `playbook.rst`_
- `dockerfile.rst`_

.. _Mantl README: https://github.com/CiscoCloud/mantl/blob/master/README.md
.. _working Ansible installation: http://docs.ansible.com/intro_installation.html#installing-the-control-machine
.. _generated dynamically: http://docs.ansible.com/intro_dynamic_inventory.html
.. _Terraform downloads: https://www.terraform.io/downloads.html
.. _inventory file: http://docs.ansible.com/intro_inventory.html
.. _Dynamic inventory for Terraform.py: https://github.com/CiscoCloud/mantl/tree/master/plugins/inventory
.. _sample.yml: https://github.com/CiscoCloud/mantl/blob/master/sample.yml
.. _playbooks: http://docs.ansible.com/ansible/playbooks.html
.. _generating ssh-keys: https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s3-openssh-rsa-keys-v2.html
.. _secure copying: https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-openssh-using-scp.html
.. _mantl/terraform/: https://github.com/CiscoCloud/mantl/tree/master/terraform
.. _openstack.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/openstack.rst
.. _gce.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/gce.rst
.. _aws.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/aws.rst
.. _digitalocean.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/digitalocean.rst
.. _vsphere.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/vsphere.rst
.. _softlayer.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/softlayer.rst
.. _dns.rst: https://github.com/CiscoCloud/mantl/blob/e53b7da545c1bdc71a5ceff7278ace5705117b41/docs/getting_started/dns.rst
.. _playbook: http://docs.ansible.com/playbooks.html
.. _GitHub project: https://github.com/CiscoCloud/nginx-mantlui
.. _security-setup: https://github.com/CiscoCloud/mantl/blob/master/docs/security/security_setup.rst
.. _ssh_users.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/ssh_users.rst
.. _playbook.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/playbook.rst
.. _dockerfile.rst: https://github.com/CiscoCloud/mantl/blob/master/docs/getting_started/dockerfile.rst
.. _907: https://github.com/CiscoCloud/mantl/issues/907
.. _927: https://github.com/CiscoCloud/mantl/issues/927


Restarting your deployment
--------------------------

To restart your deployment and make sure all components are restarted and
working correctly, use the ``playbooks/reboot-hosts.yml`` playbook.

    .. code-block:: shell

        ansible-playbook playbooks/reboot-hosts.yml

Using a Docker Container to Provision your Cluster
---------------------------------------------------

You can also provision your cluster by running a docker container. See `dockerfile.rst`_ for more information.
