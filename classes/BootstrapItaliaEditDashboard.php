<?php

class BootstrapItaliaEditDashboard
{
    public static function getDashboards($groupIdentifier = null): array
    {
        $dashboards = self::buildDashboards();
        if ($groupIdentifier) {
            $dashboards = array_filter($dashboards, function ($value) use ($groupIdentifier) {
                return $value['identifier'] == $groupIdentifier;
            });
        }
//self::dd($dashboards);
        return array_values($dashboards);
    }

    public static function buildDashboards()
    {
        $roles = eZRole::fetchObjectList(
            eZRole::definition(),
            null,
            [
                'name' => [
                    [
                        'Editor Amministrazione',
                        'Editor Novita',
                        'Editor Servizi',
                        'Editor Vivere il comune',
                        'Editor Classificazioni',
                    ],
                ],
                'version' => 0,
            ]
        );

        $ignoreContainerRemoteId = [
            'content_archive',
            'OpenPaRuoli',
        ];

        $dashboards = [];
        foreach ($roles as $role) {
            $name = str_replace('Editor ', '', $role->attribute('name'));
            $dashboard = [
                'id' => $role->attribute('id'),
                'name' => $name,
                'identifier' => eZCharTransform::instance()->transformByGroup($name, 'identifier'),
                'items' => [],
            ];
            /** @var eZPolicy $policy */
            foreach ($role->policyList() as $policy) {
                if ($policy->attribute('module_name') === 'content'
                    && $policy->attribute('function_name') === 'create') {
                    $subtree = $classes = [];
                    foreach ($policy->limitationList() as $limitation) {
                        if ($limitation->attribute('identifier') == 'Node') {
                            /** @var eZPolicyLimitationValue $value */
                            foreach ($limitation->valueList() as $value) {
                                $node = eZContentObjectTreeNode::fetch($value->attribute('value'));
                                if ($node instanceof eZContentObjectTreeNode
                                    && !in_array($node->object()->remoteID(), $ignoreContainerRemoteId)) {
                                    $subtree[$node->attribute('node_id')] = $node->attribute('name');
                                }
                            }
                        }
                        if ($limitation->attribute('identifier') == 'Subtree') {
                            /** @var eZPolicyLimitationValue $value */
                            foreach ($limitation->valueList() as $value) {
                                $node = eZContentObjectTreeNode::fetchByPath($value->attribute('value'));
                                if ($node instanceof eZContentObjectTreeNode
                                    && !in_array($node->object()->remoteID(), $ignoreContainerRemoteId)) {
                                    $subtree[$node->attribute('node_id')] = $node->attribute('name');
                                }
                            }
                        }
                        if ($limitation->attribute('identifier') == 'Class') {
                            /** @var eZPolicyLimitationValue $value */
                            foreach ($limitation->valueList() as $value) {
                                $class = eZContentClass::fetch($value->attribute('value'));
                                if ($class) {
                                    $classes[$class->attribute('identifier')] = $class;
                                }
                            }
                        }
                    }
                    if (empty($classes) || empty($subtree)){
                        continue;
                    }
                    foreach ($subtree as $nodeId => $nodeName) {
                        $createButtons = [];
                        $classIdentifiers = [];
                        foreach ($classes as $class){
                            $classIdentifiers[] = $class->attribute('identifier');
                            $createButtons[] = [
                                'class' => $class->attribute('identifier'),
                                'name' => $class->attribute('name'),
                                'parent' => $subtree,
                            ];
                        }
                        $dashboard['items'][] = [
                            'title' => $nodeName,
                            'classLength' => count($classIdentifiers),
                            'mainQuery' => 'classes [' . implode(',', $classIdentifiers) . '] subtree [' . $nodeId . ']',
                            'classes' => $classIdentifiers,
                            'createButtons' => $createButtons,
                            'columns' => [
                                ['data' => 'metadata.id', 'name' => 'id', 'title' => '#'],
                                ['data' => 'metadata.name.ita-IT', 'name' => 'name', 'title' => 'Name'],
//                                ['data' => 'metadata.classIdentifier', 'name' => 'class', 'title' => 'Class'],
                                ['data' => 'metadata.published', 'name' => 'published', 'title' => 'Published'],
                                ['data' => 'metadata.modified', 'name' => 'modified', 'title' => 'Modified'],

                            ]
                        ];
                    }
                }
            }
            $dashboards[] = $dashboard;
        }
//self::dd($dashboards);

        return $dashboards;
    }

    private static function dd($message)
    {
        echo '<pre>';
        print_r($message);
        die();
    }
}