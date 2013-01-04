CREATE TABLE "api_keys" (
  "key" varchar(32) NOT NULL,
  "user" varchar(64) NOT NULL,
  "access" smallint(6) DEFAULT NULL,
  "description" varchar(255) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_acquisitions" (
  "acquisitionid" int(11) NOT NULL PRIMARY KEY,
  "acquisition" varchar(50) NOT NULL
);

CREATE TABLE "collection_acquisitionxrefs" (
  "acquisitionxrefid" int(11) NOT NULL PRIMARY KEY,
  "acquisitionid" int(11) NOT NULL,
  "objectid" int(11) NOT NULL
);
CREATE INDEX "collection_acquisitionxrefs_1" ON "collection_acquisitionxrefs" ("acquisitionid");
CREATE INDEX "collection_acquisitionxrefs_2" ON "collection_acquisitionxrefs" ("objectid");

CREATE TABLE "collection_deptsitexrefs" (
  "deptsitexrefid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_language_codes" (
  "languageid" int(11) NOT NULL PRIMARY KEY,
  "language_code" char(2) NOT NULL
);

CREATE TABLE "collection_locations" (
  "locationid" int(11) NOT NULL PRIMARY KEY,
  "generic" varchar(64) DEFAULT NULL,
  "section" varchar(64) DEFAULT NULL,
  "area" varchar(64) NOT NULL,
  "location" varchar(64) DEFAULT NULL,
  "siteid" int(11) NOT NULL
);
CREATE INDEX "collection_locations_1" ON "collection_locations" ("section");
CREATE INDEX "collection_locations_3" ON "collection_locations" ("siteid");

CREATE TABLE "collection_movements" (
  "termid" int(10) NOT NULL PRIMARY KEY,
  "termmasterid" int(10) NOT NULL,
  "termtypeid" int(10) NOT NULL,
  "term" varchar(255) NOT NULL
);
CREATE INDEX "collection_movements_1" ON "collection_movements" ("term");

CREATE TABLE "collection_object_images" (
  "mediaxrefid" int(11) NOT NULL PRIMARY KEY,
  "objectid" int(11) NOT NULL,
  "rank" int(11) NOT NULL,
  "mediamasterid" int(11) DEFAULT NULL,
  "copyright" text,
  "fileid" int(11) DEFAULT NULL,
  "filename" varchar(255) DEFAULT NULL,
  "formatid" int(11) DEFAULT NULL,
  "pixelw" int(11) DEFAULT NULL,
  "pixelh" int(11) DEFAULT NULL,
  "duration" int(11) DEFAULT NULL,
  "filesize" int(11) DEFAULT NULL,
  "filedate" datetime DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_object_images_1" ON "collection_object_images" ("objectid");
CREATE INDEX "collection_object_images_2" ON "collection_object_images" ("formatid");

CREATE TABLE "collection_objmovementxrefs" (
  "thesxrefid" int(11) NOT NULL PRIMARY KEY,
  "id" int(11) NOT NULL,
  "termid" int(10) NOT NULL
);
CREATE INDEX "collection_objmovementxrefs_1" ON "collection_objmovementxrefs" ("id");
CREATE INDEX "collection_objmovementxrefs_2" ON "collection_objmovementxrefs" ("termid");

CREATE TABLE "collection_objsitexrefs" (
  "objsitexrefid" int(11) NOT NULL PRIMARY KEY,
  `siteid` int(11) NOT NULL,
  `objectid` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_objsitexrefs_1" ON "collection_objsitexrefs" ("siteid");
CREATE INDEX "collection_objsitexrefs_2" ON "collection_objsitexrefs" ("objectid");


CREATE TABLE "collection_objtypes" (
  "termid" int(10) NOT NULL PRIMARY KEY,
  "termmasterid" int(10) NOT NULL,
  "termtypeid" int(10) NOT NULL,
  "term" varchar(255) NOT NULL
);
CREATE INDEX "collection_objtypes_1" ON "collection_objtypes" ("term");

CREATE TABLE "collection_objtypexrefs" (
  "thesxrefid" int(11) NOT NULL PRIMARY KEY,
  "id" int(11) NOT NULL,
  "termid" int(10) NOT NULL
);
CREATE INDEX "collection_objtypexrefs_1" ON "collection_objtypexrefs" ("id");
CREATE INDEX "collection_objtypexrefs_2" ON "collection_objtypexrefs" ("termid");

CREATE TABLE "collection_sort_fields" (
  "objectid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_constituents" (
  "constituentid" int(11) NOT NULL PRIMARY KEY,
  "constituenttypeid" int(11) NOT NULL,
  "alphasort" varchar(255) DEFAULT NULL,
  "lastname" varchar(80) DEFAULT NULL,
  "firstname" varchar(48) DEFAULT NULL,
  "displayname" varchar(255) DEFAULT NULL,
  "begindate" int(11) NOT NULL,
  "enddate" int(11) NOT NULL,
  "displaydate" varchar(128) DEFAULT NULL,
  "nationality" varchar(64) DEFAULT NULL,
  "middlename" varchar(30) DEFAULT NULL,
  "suffix" varchar(20) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "collection_tms_constituents_1" ON "collection_tms_constituents" ("constituenttypeid");

CREATE TABLE "collection_tms_contypes" (
  "constituenttypeid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_conxrefs" (
  "conxrefid" int(11) NOT NULL PRIMARY KEY,
  "id" int(11) NOT NULL,
  "constituentid" int(11) NOT NULL,
  "roleid" int(11) NOT NULL,
  "displayorder" smallint(6) DEFAULT NULL,
  "displayed" tinyint(4) DEFAULT NULL,
  "active" tinyint(4) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_conxrefs_1" ON "collection_tms_conxrefs" ("id");
CREATE INDEX "collection_tms_conxrefs_2" ON "collection_tms_conxrefs" ("constituentid");
CREATE INDEX "collection_tms_conxrefs_3" ON "collection_tms_conxrefs" ("roleid");


CREATE TABLE "collection_tms_departments" (
  "departmentid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_exhibitions" (
  "exhibitionid" int(11) NOT NULL PRIMARY KEY,
  "exhtitle" varchar(255) DEFAULT NULL,
  "exhmnemonic" varchar(255) DEFAULT NULL,
  "exhtype" smallint(6) NOT NULL,
  "displayobjid" int(11) DEFAULT NULL,
  "beginisodate" varchar(10) DEFAULT NULL,
  "endisodate" varchar(10) DEFAULT NULL,
  "displaydate" varchar(128) DEFAULT NULL,
  "beginyear" smallint(6) DEFAULT NULL,
  "endyear" smallint(6) DEFAULT NULL,
  "exhtravelling" smallint(6) NOT NULL DEFAULT '0',
  "exhdepartment" int(11) NOT NULL,
  "publicinfo" tinyint(1) NOT NULL DEFAULT '0',
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_exhibitions_1" ON "collection_tms_exhibitions" ("exhdepartment");
CREATE INDEX "collection_tms_exhibitions_2" ON "collection_tms_exhibitions" ("beginisodate");
CREATE INDEX "collection_tms_exhibitions_3" ON "collection_tms_exhibitions" ("endisodate");
CREATE INDEX "collection_tms_exhibitions_4" ON "collection_tms_exhibitions" ("beginyear");
CREATE INDEX "collection_tms_exhibitions_5" ON "collection_tms_exhibitions" ("endyear");

CREATE TABLE "collection_tms_exhobjxrefs" (
  "exhobjxrefid" int(11) NOT NULL PRIMARY KEY,
  "exhibitionid" int(11) NOT NULL,
  "objectid" int(11) NOT NULL,
  "section" varchar(64) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_exhobjxrefs_1" ON "collection_tms_exhobjxrefs" ("exhibitionid");
CREATE INDEX "collection_tms_exhobjxrefs_2" ON "collection_tms_exhobjxrefs" ("objectid");
CREATE INDEX "collection_tms_exhobjxrefs_3" ON "collection_tms_exhobjxrefs" ("section");

CREATE TABLE "collection_tms_languages" (
  "languageid" int(11) NOT NULL PRIMARY KEY,
  "language" varchar(64) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_tms_mediaformats" (
  "formatid" int(11) NOT NULL PRIMARY KEY,
  `mediatypeid` int(11) NOT NULL,
  `format` varchar(64) NOT NULL,
  `viewerid` tinyint(4) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_mediaformats_1" ON "collection_tms_mediaformats" ("mediatypeid");

CREATE TABLE "collection_tms_mediatypes" (
  "mediatypeid" int(11) NOT NULL PRIMARY KEY,
  `mediatype` varchar(64) NOT NULL,
  `isdigital` tinyint(1) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_tms_objcontext" (
  "objcontextid" int(11) NOT NULL PRIMARY KEY,
  "objectid" int(11) NOT NULL,
  "culture" varchar(64) DEFAULT NULL,
  "style" varchar(64) DEFAULT NULL,
  "reign" varchar(64) DEFAULT NULL,
  "dynasty" varchar(64) DEFAULT NULL,
  "period" varchar(64) DEFAULT NULL,
  "movement" varchar(64) DEFAULT NULL,
  "nationality" varchar(64) DEFAULT NULL,
  "school" varchar(64) DEFAULT NULL,
  "shorttext1" varchar(255) DEFAULT NULL,
  "shorttext2" varchar(255) DEFAULT NULL,
  "shorttext3" varchar(255) DEFAULT NULL,
  "shorttext4" varchar(255) DEFAULT NULL,
  "longtext1" text,
  "longtext2" text,
  "longtext3" text,
  "longtext4" text,
  "longtext5" text,
  "longtext6" text,
  "n_name" text,
  "n_title" text,
  "n_description" text,
  "n_signed" text,
  "n_markings" text,
  "n_inscription" text,
  "n_notes" text,
  "n_curatorremarks" text,
  "flag1" tinyint(4) NOT NULL,
  "flag2" tinyint(4) NOT NULL,
  "flag3" tinyint(4) NOT NULL,
  "flag4" tinyint(4) NOT NULL,
  "flag5" tinyint(4) NOT NULL,
  "flag6" tinyint(4) NOT NULL,
  "flag7" tinyint(4) NOT NULL,
  "flag8" tinyint(4) NOT NULL,
  "flag9" tinyint(4) NOT NULL,
  "flag10" tinyint(4) NOT NULL,
  "isodate1" varchar(10) DEFAULT NULL,
  "isodate2" varchar(10) DEFAULT NULL,
  "isodate3" varchar(10) DEFAULT NULL,
  "isodate4" varchar(10) DEFAULT NULL,
  "isodate5" varchar(10) DEFAULT NULL,
  "isodate6" varchar(10) DEFAULT NULL,
  "isodate7" varchar(10) DEFAULT NULL,
  "isodate8" varchar(10) DEFAULT NULL,
  "isodate9" varchar(10) DEFAULT NULL,
  "isodate10" varchar(10) DEFAULT NULL,
  "integer1" int(11) DEFAULT NULL,
  "integer2" int(11) DEFAULT NULL,
  "integer3" int(11) DEFAULT NULL,
  "integer4" int(11) DEFAULT NULL,
  "authority1id" int(11) DEFAULT NULL,
  "authority2id" int(11) DEFAULT NULL,
  "authority3id" int(11) DEFAULT NULL,
  "authority4id" int(11) DEFAULT NULL,
  "flag11" tinyint(4) DEFAULT NULL,
  "flag12" tinyint(4) DEFAULT NULL,
  "flag13" tinyint(4) DEFAULT NULL,
  "flag14" tinyint(4) DEFAULT NULL,
  "flag15" tinyint(4) DEFAULT NULL,
  "flag16" tinyint(4) DEFAULT NULL,
  "flag17" tinyint(4) DEFAULT NULL,
  "flag18" tinyint(4) DEFAULT NULL,
  "flag19" tinyint(4) DEFAULT NULL,
  "flag20" tinyint(4) DEFAULT NULL,
  "longtext7" text,
  "longtext8" text,
  "longtext9" text,
  "longtext10" text,
  "shorttext5" varchar(255) DEFAULT NULL,
  "shorttext6" varchar(255) DEFAULT NULL,
  "shorttext7" varchar(255) DEFAULT NULL,
  "shorttext8" varchar(255) DEFAULT NULL,
  "shorttext9" varchar(255) DEFAULT NULL,
  "shorttext10" varchar(255) DEFAULT NULL,
  "authority5id" int(11) DEFAULT NULL,
  "authority6id" int(11) DEFAULT NULL,
  "authority7id" int(11) DEFAULT NULL,
  "authority8id" int(11) DEFAULT NULL,
  "authority9id" int(11) DEFAULT NULL,
  "authority10id" int(11) DEFAULT NULL,
  "authority11id" int(11) DEFAULT NULL,
  "authority12id" int(11) DEFAULT NULL,
  "authority13id" int(11) DEFAULT NULL,
  "authority14id" int(11) DEFAULT NULL,
  "authority15id" int(11) DEFAULT NULL,
  "authority16id" int(11) DEFAULT NULL,
  "authority17id" int(11) DEFAULT NULL,
  "authority18id" int(11) DEFAULT NULL,
  "authority19id" int(11) DEFAULT NULL,
  "authority20id" int(11) DEFAULT NULL,
  "authority21id" int(11) DEFAULT NULL,
  "authority22id" int(11) DEFAULT NULL,
  "authority23id" int(11) DEFAULT NULL,
  "authority24id" int(11) DEFAULT NULL,
  "authority25id" int(11) DEFAULT NULL,
  "authority26id" int(11) DEFAULT NULL,
  "authority27id" int(11) DEFAULT NULL,
  "authority28id" int(11) DEFAULT NULL,
  "authority29id" int(11) DEFAULT NULL,
  "authority30id" int(11) DEFAULT NULL,
  "authority31id" int(11) DEFAULT NULL,
  "authority32id" int(11) DEFAULT NULL,
  "authority33id" int(11) DEFAULT NULL,
  "authority34id" int(11) DEFAULT NULL,
  "authority35id" int(11) DEFAULT NULL,
  "authority36id" int(11) DEFAULT NULL,
  "authority37id" int(11) DEFAULT NULL,
  "authority38id" int(11) DEFAULT NULL,
  "authority39id" int(11) DEFAULT NULL,
  "authority40id" int(11) DEFAULT NULL,
  "authority41id" int(11) DEFAULT NULL,
  "authority42id" int(11) DEFAULT NULL,
  "authority43id" int(11) DEFAULT NULL,
  "authority44id" int(11) DEFAULT NULL,
  "authority45id" int(11) DEFAULT NULL,
  "authority46id" int(11) DEFAULT NULL,
  "authority47id" int(11) DEFAULT NULL,
  "authority48id" int(11) DEFAULT NULL,
  "authority49id" int(11) DEFAULT NULL,
  "authority50id" int(11) DEFAULT NULL,
  "authority51id" int(11) DEFAULT NULL,
  "authority52id" int(11) DEFAULT NULL,
  "authority53id" int(11) DEFAULT NULL,
  "authority54id" int(11) DEFAULT NULL,
  "authority55id" int(11) DEFAULT NULL,
  "authority56id" int(11) DEFAULT NULL,
  "authority57id" int(11) DEFAULT NULL,
  "authority58id" int(11) DEFAULT NULL,
  "authority59id" int(11) DEFAULT NULL,
  "authority60id" int(11) DEFAULT NULL,
  "authority61id" int(11) DEFAULT NULL,
  "authority62id" int(11) DEFAULT NULL,
  "authority63id" int(11) DEFAULT NULL,
  "authority64id" int(11) DEFAULT NULL,
  "authority65id" int(11) DEFAULT NULL,
  "authority66id" int(11) DEFAULT NULL,
  "authority67id" int(11) DEFAULT NULL,
  "authority68id" int(11) DEFAULT NULL,
  "authority69id" int(11) DEFAULT NULL,
  "authority70id" int(11) DEFAULT NULL,
  "authority71id" int(11) DEFAULT NULL,
  "authority72id" int(11) DEFAULT NULL,
  "authority73id" int(11) DEFAULT NULL,
  "authority74id" int(11) DEFAULT NULL,
  "authority75id" int(11) DEFAULT NULL,
  "authority76id" int(11) DEFAULT NULL,
  "authority77id" int(11) DEFAULT NULL,
  "authority78id" int(11) DEFAULT NULL,
  "authority79id" int(11) DEFAULT NULL,
  "authority80id" int(11) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_objcontext_1" ON "collection_tms_objcontext" ("objectid");
CREATE INDEX "collection_tms_objcontext_2" ON "collection_tms_objcontext" ("flag5");

CREATE TABLE "collection_tms_objdeaccession" (
  "deaccessionid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_objectlevels" (
  "objectlevelid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_objects" (
  "objectid" int(11) NOT NULL PRIMARY KEY,
  "objectnumber" varchar(24) NOT NULL,
  "sortnumber" varchar(32) NOT NULL,
  "departmentid" int(11) NOT NULL,
  "datebegin" int(11) NOT NULL,
  "dateend" int(11) NOT NULL,
  "dated" varchar(80) DEFAULT NULL,
  "medium" text,
  "dimensions" text,
  "creditline" text,
  "publicaccess" smallint(6) NOT NULL,
  "curatorapproved" smallint(6) NOT NULL,
  "objectlevelid" int(11) DEFAULT NULL,
  "edition" text,
  "sort_title" varchar(255) DEFAULT NULL,
  "sort_constituent" varchar(255) DEFAULT NULL,
  "sort_date" float NOT NULL,
--  "sort_location" varchar(64) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_objects_1" ON "collection_tms_objects" ("departmentid");
CREATE INDEX "collection_tms_objects_2" ON "collection_tms_objects" ("objectlevelid");
CREATE INDEX "collection_tms_objects_3" ON "collection_tms_objects" ("datebegin");
CREATE INDEX "collection_tms_objects_4" ON "collection_tms_objects" ("dateend");
CREATE INDEX "collection_tms_objects_5" ON "collection_tms_objects" ("publicaccess");
CREATE INDEX "collection_tms_objects_6" ON "collection_tms_objects" ("curatorapproved");
CREATE INDEX "collection_tms_objects_7" ON "collection_tms_objects" ("sort_title");
CREATE INDEX "collection_tms_objects_8" ON "collection_tms_objects" ("sort_constituent");
CREATE INDEX "collection_tms_objects_9" ON "collection_tms_objects" ("sort_date");


CREATE TABLE "collection_tms_objtitles" (
  "titleid" int(11) NOT NULL PRIMARY KEY,
  "objectid" int(11) NOT NULL,
  "titletypeid" int(11) NOT NULL,
  "title" varchar(255) NOT NULL,
  "remarks" varchar(255) DEFAULT NULL,
  "active" smallint(6) NOT NULL,
  "displayorder" smallint(6) DEFAULT NULL,
  "displayed" tinyint(4) DEFAULT NULL,
  "languageid" int(11) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "collection_tms_objtitles_1" ON "collection_tms_objtitles" ("titletypeid");
CREATE INDEX "collection_tms_objtitles_2" ON "collection_tms_objtitles" ("objectid");
CREATE INDEX "collection_tms_objtitles_3" ON "collection_tms_objtitles" ("languageid");

CREATE TABLE "collection_tms_roles" (
  "roleid" int(11) NOT NULL PRIMARY KEY,
  "roletypeid" int(11) NOT NULL,
  "role" varchar(32) NOT NULL,
  "prepositional" varchar(64) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_tms_sites" (
  "siteid" int(11) NOT NULL PRIMARY KEY,
  `sitename` varchar(80) DEFAULT NULL,
  `sitenumber` varchar(24) NOT NULL,
  `sitesortnumber` varchar(32) NOT NULL,
  `sitestatusid` int(11) NOT NULL,
  `historicalnotes` text,
  `legalnotes` text,
  `locationnotes` text,
  `remarks` text,
  `description` text,
  `condition` varchar(255) DEFAULT NULL,
  `dimensions` varchar(255) DEFAULT NULL,
  `environment` text,
  `researchactivity` text,
  `researchercomments` text,
  `ispublic` tinyint(1) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `sitetypeid` int(11) NOT NULL,
  `siteclassificationid` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_tms_terms" (
  "termid" int(10) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_textentries" (
  "textentryid" int(11) NOT NULL PRIMARY KEY,
  "tableid" int(11) NOT NULL,
  "id" int(11) NOT NULL,
  "texttypeid" int(11) NOT NULL,
  "textstatusid" int(11) NOT NULL,
  "purpose" varchar(255) DEFAULT NULL,
  "textentry" text,
  "textdate" varchar(10) DEFAULT NULL,
  "authorconid" int(11) DEFAULT NULL,
  "remarks" varchar(1000) DEFAULT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "collection_tms_thesxrefs" (
  "thesxrefid" int(11) NOT NULL PRIMARY KEY
);

CREATE TABLE "collection_tms_titletypes" (
  "titletypeid" int(11) NOT NULL PRIMARY KEY,
  "titletype" varchar(64) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO `collection_tms_exhibitions` VALUES(
  1, 'Past Exhibition', 'pastexhibition', 0, 0, '2012-10-05', '2013-01-23', 
  'October 5, 2012 - January 23, 2013', 2012, 2013, 0, 0, 0, '2012-09-14 18:07:38');
INSERT INTO `collection_tms_exhibitions` VALUES(
  2, 'Current Exhibition', 'currentexhibition', 0, 0, '2012-10-05', '2013-01-23', 
  'October 5, 2012 - January 23, 2013', 2012, 2013, 0, 0, 0, '2012-09-14 18:07:38');
INSERT INTO `collection_tms_exhibitions` VALUES(
  3, 'Future Exhibition', 'futureexhibition', 0, 0, '2012-10-05', '2013-01-23', 
  'October 5, 2012 - January 23, 2013', 2012, 2013, 0, 0, 0, '2012-09-14 18:07:38');

INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(1, 1, 1867, 'Ramp 1, Bay 14', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(2, 2, 1867, 'Ramp 2, Bay 27', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(3, 3, 1867, 'High Gallery', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(4, 1, 1487, 'Ramp 1, Bay 12', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(5, 1, 13142, 'Ramp 5, Bay 57', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(6, 2, 25905, 'Ramp 6, Bay 63', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(7, 2, 3417, 'Ramp 2, Bay 21', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs`
   VALUES(8, 3, 1972, 'Ramp 1, Bay 12', '2012-10-02 14:32:58');
INSERT INTO `collection_tms_exhobjxrefs` 
  VALUES(9, 3, 783, 'Ramp 5, Bay 57', '2012-10-02 14:32:58');

CREATE TABLE IF NOT EXISTS `api_keys` (
  "key" varchar(32) NOT NULL PRIMARY KEY,
  "user" varchar(64) NOT NULL,
  "access" smallint(6) DEFAULT NULL,
  "description" varchar(255) NOT NULL,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO `api_keys` (`key`, `user`, `access`, `description`, `updated_at`) 
  VALUES ('00ea1ae3bd1fef315ba91d2ad8a125ad', 'unit_test_cancelled', 0, 
    'Test key: exists but no access', '2012-08-09 20:10:25');
INSERT INTO `api_keys` (`key`, `user`, `access`, `description`, `updated_at`) 
  VALUES ('ed3c63916af176b3af878f98156e07f4', 'unit_test_good', 17, 
    'Test key: valid', '2012-08-09 21:37:06');

