CREATE ROLE "domsFieldSearch" LOGIN PASSWORD 'domsFieldSearchPass'
NOINHERIT CREATEDB
VALID UNTIL 'infinity';

CREATE DATABASE "domsFieldSearch"
WITH
TEMPLATE=template0
ENCODING='SQL_ASCII'
OWNER="domsFieldSearch";


CREATE ROLE "domsMPT" LOGIN PASSWORD 'domsMPTPass'
NOINHERIT CREATEDB
VALID UNTIL 'infinity';

CREATE DATABASE "domsMPT"
WITH
TEMPLATE=template0
ENCODING='SQL_ASCII'
OWNER="domsMPT";


CREATE ROLE "domsUpdateTracker" LOGIN PASSWORD 'domsUpdateTrackerPass'
VALID UNTIL 'infinity';

CREATE DATABASE "domsUpdateTracker"
WITH
TEMPLATE=template0
ENCODING='SQL_ASCII'
OWNER="domsUpdateTracker";


CREATE ROLE "xmltapesIndex" LOGIN PASSWORD 'xmltapesIndexPass'
VALID UNTIL 'infinity';

CREATE DATABASE "xmltapesObjectIndex"
WITH
TEMPLATE=template0
ENCODING='UTF8'
OWNER="xmltapesIndex";

CREATE DATABASE "xmltapesDatastreamIndex"
WITH
TEMPLATE=template0
ENCODING='UTF8'
OWNER="xmltapesIndex";

\connect "xmltapesObjectIndex";

CREATE TABLE "storeindex" (
  id VARCHAR(255) PRIMARY KEY,
  tapename VARCHAR(255) NOT NULL,
  tapeoffset BIGINT NOT NULL
);
ALTER TABLE "storeindex" OWNER TO "xmltapesIndex";

CREATE TABLE "indexed" (
  tapename VARCHAR(255) NOT NULL PRIMARY KEY
);
ALTER TABLE "indexed" OWNER TO "xmltapesIndex";


\connect "xmltapesDatastreamIndex"

CREATE TABLE "storeindex" (
  id VARCHAR(255) PRIMARY KEY,
  tapename VARCHAR(255) NOT NULL,
  tapeoffset BIGINT NOT NULL
);
ALTER TABLE "storeindex" OWNER TO "xmltapesIndex";

CREATE TABLE "indexed" (
  tapename VARCHAR(255) NOT NULL PRIMARY KEY
);
ALTER TABLE "indexed" OWNER TO "xmltapesIndex";
