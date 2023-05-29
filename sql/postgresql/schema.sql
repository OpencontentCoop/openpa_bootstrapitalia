CREATE TABLE openpabootstrapitaliaicon
(
  node_id   integer      not null default 0,
  contentobject_attribute_id integer DEFAULT 0 NOT NULL,
  icon_text varchar(255) NOT NULL default ''
);

ALTER TABLE ONLY openpabootstrapitaliaicon
  ADD CONSTRAINT openpabootstrapitaliaicon_pkey PRIMARY KEY (node_id, icon_text);

CREATE INDEX openpabootstrapitaliaicon_key ON openpabootstrapitaliaicon USING btree (node_id, icon_text);

CREATE TABLE openpacomuniitaliani
(
    comune varchar(255) NOT NULL default '',
    name_normalized varchar(255) NOT NULL default '',
    pro_com_t varchar(255) NOT NULL default '',
    den_prov varchar(255) default '',
    sigla varchar(255) default '',
    den_reg varchar(255) default '',
    cod_reg integer default 0
);

ALTER TABLE ONLY openpacomuniitaliani
    ADD CONSTRAINT openpacomuniitaliani_pkey PRIMARY KEY (pro_com_t);

CREATE INDEX openpacomuniitaliani_key ON openpacomuniitaliani USING btree (comune, name_normalized);