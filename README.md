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

(may take a few minutes and download quite a bit the first time)


Inside vagrant:
===

Install DOMS, SBOI and Summa: (takes a few minutes)

     vagrant ssh -c /vagrant/install_doms.sh

Wait up to several minutes until SBOI Solr is ready and answers on link below.

Download and install Zookeeper, and the two autonomous components:  batch-trigger, doms-ingester:

    vagrant ssh -c /vagrant/setup-newspapers.sh

Create target folder:

    vagrant ssh -c "sudo mkdir /newspapr_batches; sudo chown vagrant /newspapr_batches; sudo chmod 755 /newspapr_batches"

Put batches in /newspapr-batches _inside_ vagrant machine:

    vagrant scp ~/ownCloud/2016-02-29/llo/standard\ pakker\ til\ repo/avis/Fjerritslev\ avis/. /newspapr_batches

Update SBIO index, and run each of the autonomous components:

    vagrant ssh -c /vagrant/newspapers_poll.sh
    vagrant ssh -c /vagrant/newspapers_poll.sh
    vagrant ssh -c /vagrant/newspapers_poll.sh



Extra:
===

Access Fedora:

    http://localhost:7880/fedora/objects

Access SBOI Solr:

    http://localhost:58608/newspapr/sbsolr/#/collection1/query

Access DOMS Wui Solr:

    http://localhost:58708/domswui/sbsolr/#/collection1/query