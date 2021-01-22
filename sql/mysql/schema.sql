CREATE TABLE `openpabootstrapitaliaicon` (
 `node_id` int(11) NOT NULL DEFAULT '0',
 `contentobject_attribute_id` int(11) NOT NULL DEFAULT '0',
 `icon_text` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `openpabootstrapitaliaicon`
    ADD PRIMARY KEY (`node_id`,`icon_text`);