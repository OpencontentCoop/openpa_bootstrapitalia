CREATE TABLE openpabootstrapitaliaicon
(
  node_id   integer      not null default 0,
  contentobject_attribute_id integer DEFAULT 0 NOT NULL,
  icon_text varchar(255) NOT NULL default ''
);

ALTER TABLE ONLY openpabootstrapitaliaicon
  ADD CONSTRAINT openpabootstrapitaliaicon_pkey PRIMARY KEY (node_id, icon_text);

CREATE INDEX openpabootstrapitaliaicon_key ON openpabootstrapitaliaicon USING btree (node_id, icon_text);

CREATE TABLE eztags_description (
   keyword_id integer not null default 0,
   description_text TEXT,
   locale varchar(255) NOT NULL default '',
   PRIMARY KEY (keyword_id, locale)
);