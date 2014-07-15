2014-07-15 Release 1.8
* Updated to version 1.0.9 of xmltapes, which fixed the "Corrupt tapes on purge" bug.

2014-06-23 Release 1.7
* Updated to version 1.0.8 of xmltapes. Removing open files leak on errors, and stops urlencoding filenames in tapes.

2014-06-19 Release 1.6
* Fixed a bad bug in tapes (1.0.7),  that made upgrading from an old doms impossible

2014-06-18 Release 1.5
* Update to 1.0.6 of xmltapes. This fixes the bug that would cause data loss by deleting source metadata files regardless of them being succesfully written to the tapes or not. 
* The testbed has two summa instances deployed (one for SBOI, another for searching doms, as used by DomsGUI).
* The project has been vagrant enabled, i.e. making it easy to setup a virtual machine with a running doms, for development purposes. 
* Enable the validator hook.
* Use the newest base objects ingester 1.5, with various improvements to newspaper datamodel and various fixes for radiotv datamodel
* Use version 1.3 of doms-server for improved error messages, and better search
* Use version 1.1 of ecm module to get exceptions from failed validations

2014-04-04 Release 1.4
* Updated to 1.0.5 of xmltapes. This fixes a nasty bug introduced in the previous release, where some tapes used the extension ".gz.tar" and others the extension ".tar". To upgrade, rename all the xmltapes to .tar. Then update the akubra-config.xml to set rebuild true and restart the doms. After this first restart, you can set rebuild to false again.
* Doms can now shut down correctly again.

2014-03-31 Release 1.3

* Updated to xml tapes 1.0.4 which have configurable tape names
* Tape archives are now named '.tar', not '.tgz'. Existing files must be renamed and the redis database rebuild when upgrading
* Updated to centralWebservice 1.2 which fixes a timezone bug when retrieving old versions of a datastream
* Vagranised
* Use the newest base objects ingester 1.4
* Made a very configurable install procedure
* Made the small.sh script to enable an install with very few features, perfect for integration tests

2014-01-16 Release 1.2

* Upgraded to version 1.0.3 of CentralWebservice. This should fix the bug for summa indexing of objects
* with managed datastreams
* Updated to Summa newspapr 1.2

2014-01-08 Release 1.1

* Updated to Summa newspapr 1.1.1
* Updated to XmlTapes v. 1.0.2
* Summa folders (dump,storage,index...) is no longer created in the install dir, but rather in the data dir


2013-11-22 Release 1.0

Versions:

* Update all dependencies to 1.0 released versions
* Use the newer 0.0.9 radio tv ingester
* Removed the "deny change of published objects" and the "deny purge" policy

Summarise:

* Comment where to find summarise repo
* Update Summarise config template to include SBOI
* Update Summarise dependency
* Should bundle and install the summa integration now
* Updated to version 0.5 of domsgui summarise
* New summarise domsgui site

Bugs:

* Fix the cannot install problem when outside SB
* Hopefully fixed the logback no line break error
* Create the summix storage folder before using it
* Log all doms events, not just the ones from central
* Don't sync updates
* Included the mulgara timeout fix

XmlTapes:

* The datastream store is also taped now, as we will use managed datastreams
* Use Xml Tapes

General:

* Updated to use fedora 3.6.2
* Update scripts to match production


3/4/2013 Release version 0.12.0

* Update docs and configuration

22/3/2013 Release version 0.11.3

* Remove web services for obsolete bit repository
* Remove web services for update tracker and ecm, now integrated as libraries in central doms web service
* Update authchecker dependency to version 0.0.12
    * support for authorization on object pids rather than URL's
* Update doms central webservice dependency to 0.0.27
    - use a Summa indexing engine for searching
    - support for object behaviours (methods and links)
    - support for historic views of object bundles
    - remove old bit repository webservice dependencies
    - Internalize ecm and update tracker dependencies as libraries, rather than use them as web services
* Require a Summa indexing engine

2/5/2011 Release version 0.11.2

* Build both packages with and wothout ingesters when packaging.
* Fix logging configuration issues.

24/1/2012 Release version 0.11.1

* Updated to 0.26 central webservice , fixing a memory bug when loading content model labels

* Updated the shard metadata schema

13/12/2011 Release version 0.11.0

* Added the FFPROBE datastream to radiotv file objects

* Use updatetracker 0.0.14
 * Cleaned up the branch/revert naming problems, and renamed some modules

* Shard is not entry content model for view BES

* DomsCentral 0.0.24
  * Use the 0.0.14 updatetracker




2/11/2011 Release version 0.10.24

* Updated Radio TV Program Schema with GUI annotations

* Pulled in new releases of doms webservices

* ShardMetadata - channelId optional

* Added schema for Shard metadata

* Reverted to the old working version of the updatetracker

* Integrated with AD system - completed

* New version of DomsCentral 0.0.23
    * Updated to newest doms.pom
    * fixed broken methods (relation add/remove)
    * ObjectProfile with support for more types of objects (Collections, File objects)
    * GetObjectsInCollection



19/9/2011 Release version 0.10.23

* Updated authchecker to version 0.0.11
   * Creating Added admin user
   * Admin users remain for 2 days
   * Fixed a Rest interface problem

* Integrated with AD system - begun

* Updated base objects with GUI annotations

* New version of DomsCentral 0.0.22
   * with fedora fieldsearch support (to be removed when summa integration is complete)
   * DatastreamProfile method
   * ObjectProfile method
   * Inverse relations
   * Temp Usercreation - AD stuff


30/6/2011 Release version 0.10.22

* Disabled checksum checking on template datastreams that are updated

* Actually fixed the things that made the ingester go boom (remove checksum checking from template datastreams with IDs).

20/6/2011 Release version 0.10.21

* Updated to use the newest ECM (0.0.18). The previous one had a bug when cloning files.

* Updated the batch objects, there were numerous errors in these.

* Updated the radio tv policy to include the faculty group and other fixes to license..

* Fixed some things that made the ingester go boom.

* Removed the default // stuff in paths

* Removed the empty services/conf/fedora dir, that was not used any more

* Added the staff@hum.au.dk role to the radio tv license

11/4/2011 Release of version 0.10.20.1

* Fixed a very minor bug in package.sh that prevented install with postgresql database

8/4/2011 Release of version 0.10.20

* Made the doms ingester optional, so it will not be bundled in the release

* Fixed the errors in the log4j config files

* Removed the version numbers from the war files, and removed the symlink stuff

* Moved schemas to live in services/

* Moved schemaStore.xml to live in services/tomcat-apps

* Removed the services/tomcatapps folder. The warfiles are now in services/webapps

* Brought the changelog up2date

1/4/2011 Release of version 0.10.19

* Changed the build system to maven, instead of ant

* Renamed the doms webservices (rather, a natural consequence of maven)

* Updated log4j config files to use rolling file appenders

* Added the ingester as an dependency, and some example preingest files

* Updated the system to create basic objects, to use the fedora batch process

* Added the SchemaStore pseudo process

* Updated the authchecker service to 0.0.10
    - changed the interface
    - Made the tickets carry more info


28/1/2011 Release of version 0.10.18

* Changed logging levels back to DEBUG

* Upgraded all services, so that they include the proper surveillance libs

* Fixed the xacml path problem in fedora.fcfg

26/1/2011 Release of version 0.10.17 - Second official Release

* updated the logging configurations, so that we log on INFO in
individuals files, and WARN in the doms.log file.

* Updated base objects so that
   1. removed the big pbcore placeholder from template_program, as it was clogging up the summa
   2. made all RELS-EXT datastreams versionable
   3. Split the RadioTV_License into adminOnlyLicense, and inhouseLicense
   4. Updated all the objects to not use POLICY datastreams, if they were only referring to the default open License. This speeds up ingests x2.
   5. Fixed the wrong formatURI/mimetype in the POLICY datastreams

*  Updated fedora to version 3.4.2.Should not have any incompabilities aas we were using a maintenance snapshot before

*  Updated ECM to version 0.0.13, so that it does not cause "deprecated" warnings in fedora.log

*  Removed unneeded things from fedora.fcfg

*  Policies moved from TOMCAT_CONF_DIR/fedora to FEDORA_DIR

*  Added fedora.home to context.xml

17/1/2011 Release of version 0.10.16 - First official release, changelog begins here
