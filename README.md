Outside vagrant:
===

After cloning checkout devel-config using:

    git -C src/vagrant/ clone -b TRA ssh://git@sbprojects.statsbiblioteket.dk:7999/avis/devel-config.git

Create artifacts to deploy:

    mvn clean install

Install the vagrant timezone fix
    
    vagrant plugin install vagrant-timezone

Start vagrant:

    cd src/vagrant
    vagrant up --provider virtualbox



Inside vagrant:
===



Install vagrant scp plugin:
http://stackoverflow.com/a/28359455/4527948

    vagrant plugin install vagrant-scp


Go inside vagrant:

    vagrant ssh

Install VisualVM, DOMS, SBOI and Summa: (takes a few minutes)

     /vagrant/install_doms.sh

Download and install Zookeeper, and the two autonomous components:  batch-trigger, doms-ingester:

    /vagrant/setup-newspapers.sh

Put batches in /newspapr-batches _inside_ vagrant machine:

    vagrant scp '~/ownCloud/2016-02-29/llo/standard\ pakker\ til\ repo/avis/Fjerritslev\ avis/*' /newspapr_batches


Update SBIO index, and run each of the autonomous components:

    /vagrant/newspapers_poll.sh
    /vagrant/newspapers_poll.sh
    /vagrant/newspapers_poll.sh




Extra:
===

Access Fedora:

    http://localhost:7880/fedora/objects

Access SBOI Solr:

    http://localhost:58608/newspapr/sbsolr/#/collection1/query

Access DOMS Wui Solr:

    http://localhost:58708/domswui/sbsolr/#/collection1/query