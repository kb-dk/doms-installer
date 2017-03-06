Overview
---

This project contains the doms-installer.

The purpose is to combine the various parts into a single bundle which
can be made deployed to e.g. sbforge Nexus in order to be available to
other projects as maven artifacts.

See
https://sbforge.org/nexus/index.html#nexus-search;gav~dk.statsbiblioteket.doms.installer~doms-installer~~~~kw,versionexpand
for currently available artifacts.

As of 1.26-SNAPSHOT a pom is installed with 
"doms-installer-...-installer.tar.gz" and
"doms-installer-...-testbed.tar.gz" attached.


vagrant
---

NOTE: DO NOT USE THE FILES HERE AS-IS!

ABR did some initial work on making DOMS run in a vagrant image which
was put here for lack of a better location and was then forked and
adapted by TRA for usage in the digital-pligtaflevering-aviser-tools
project in order to have local developer instance of
DOMS+Bitrepository.

As of 1.26-SNAPSHOT these changes has been backported to allow
refactoring the DPA project to use the Maven artifacts generated (and
the files left as-is for informational purposes).  See the DPA project
for the latest development

See VAGRANT.md for more details.



