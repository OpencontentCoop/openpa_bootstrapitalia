<?php /* #?ini charset="utf-8"?

[ConnectorSettings]
AvailableConnectors[]=essential
AvailableConnectors[]=add_place
AvailableConnectors[]=valuation
AvailableConnectors[]=remote_dashboard_select_target
AvailableConnectors[]=remote_dashboard_map_target
AvailableConnectors[]=remote_dashboard_manage_relations
AvailableConnectors[]=remote_dashboard_import

[essential_ConnectorSettings]
PHPClass=\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector
OnlyRequired=true

[add_place_ConnectorSettings]
PHPClass=\Opencontent\Ocopendata\Forms\Connectors\OpendataConnector
ClassConnector=AddPlaceClassConnector
OnlyRequired=true

[valuation_ConnectorSettings]
PHPClass=ValuationConnector

[remote_dashboard_select_target_ConnectorSettings]
PHPClass=RemoteDashboardSelectTargetConnector

[remote_dashboard_map_target_ConnectorSettings]
PHPClass=RemoteDashboardMapTargetConnector

[remote_dashboard_manage_relations_ConnectorSettings]
PHPClass=RemoteDashboardManageRelationsConnector

[remote_dashboard_import_ConnectorSettings]
PHPClass=RemoteDashboardImportConnector


*/ ?>