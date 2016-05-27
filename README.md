Before starting:
===

The version of Vagrant shipping with Ubuntu 16.04 is 1.7.4.  Snapshot functionality in vagrant itself requires
1.8.1.  If you need this install vagrant yourself.

Note:  For now, use the VirtualBox GUI to restore snapshots.  "bootstrap.sh" is not properly
written to reprovision the virtual machine as invoked with "vagrant snapshot restore".

Outside vagrant:
===

After cloning checkout devel-config using:

    git -C src/vagrant/ clone -b TRA ssh://git@sbprojects.statsbiblioteket.dk:7999/avis/devel-config.git

Create artifacts to deploy:

    mvn clean install

Install the necessary vagrant plugins: http://stackoverflow.com/a/28359455/4527948

    vagrant plugin install vagrant-timezone
    vagrant plugin install vagrant-scp

Start vagrant (using virtualbox provider):

    cd src/vagrant
    vagrant up

(may take 5-10 minutes and download quite a bit the first time).

    vagrant ssh -c "nohup bash -x /vagrant/install_doms.sh; nohup bash -x /vagrant/setup-newspapers.sh"

SBOI and DOMS Wui Solr will take a while to initialize.  Check
the URLs below to see when they are ready and responsive.

You now have a local, empty DOMS.

Create a snapshot to be able to easily revert to this point.

    vagrant snapshot save up

Do not use the VirtualBox gui to save and restore snapshots.  The
file system mappings will not be properly handled.


Inside vagrant:
===

Put batches in /newspapr-batches _inside_ vagrant machine: (link valid for PC599)

    vagrant scp ~/ownCloud/2016-02-29/llo/standard\ pakker\ til\ repo/avis/Fjerritslev\ avis/. /newspapr_batches

Update SBIO index, and run each of the autonomous components:

    vagrant ssh -c /vagrant/newspapers_poll.sh

This command invokes several batch scripts to ensure all the work has been done.
It is very important to do so, as the index must be up to date for the DOMS
query routines to see any updates.  Repeat after each change to DOMS data.


Notes:
===

Use

    vagrant suspend

to stop working instead of "vagrant halt" as efforts have not yet been
done to ensure production quality of this image.


Links work both inside vagrant box and outside.

Access Fedora (fedoraAdmin/fedoraAdminPass):

    http://localhost:7880/fedora/objects

Access SBOI Solr:

    http://localhost:58608/newspapr/sbsolr/#/collection1/query

Access DOMS Wui Solr:

    http://localhost:58708/domswui/sbsolr/#/collection1/query

Local pid generator:

    http://localhost:7880/pidgenerator-service/rest/pids/generatePid
