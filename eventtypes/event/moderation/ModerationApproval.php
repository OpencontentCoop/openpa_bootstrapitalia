<?php

/* Maybe use?
 * CREATE OR REPLACE VIEW moderation AS
 * SELECT ezcollab_item.*, ezapprove_items.workflow_process_id
 * FROM ezcollab_item JOIN ezapprove_items ON (ezapprove_items.collaboration_id = ezcollab_item.id)
 */

class ModerationApproval
{
    public $id;

    public $contentObjectId;

    public $contentObjectVersionId;

    public $contentObjectVersionLanguage;

    public $status;

    public $classIdentifier;

    public $title;

    public $createdAt;

    public $authorId;

    public $processId;

    public $mainAssignmentId;

    private $attributes = [];

    public static function fetchList(int $limit, int $offset = 0, $filters = [], $groupByObjectId = true): array
    {
        $conditionsString = self::parseFiltersToSqlConditions($filters);
        $query = '';
        if ($groupByObjectId) {
            $query .= 'with grouped as (';
        }
        $query .= "select ezcollab_item.*, ezworkflow_process.id as workflow_process_id from ezcollab_item 
                full join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id) 
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1)
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation' 
                $conditionsString
                order by ezcollab_item.created desc";
        if ($groupByObjectId) {
            $query .= ') select data_int1 as object_id, count(data_int1) as count, max(created) as latest, ';
            $query .= "json_agg(
                    json_build_object(
                        'id', id,
                        'created', created,
                        'data_int1', data_int1,
                        'data_int2', data_int2,
                        'data_text3', data_text3,
                        'data_int3', data_int3,
                        'data_text1', data_text1,
                        'data_text2', data_text2,                        
                        'data_float2', data_float2,
                        'workflow_process_id', workflow_process_id,
                        'data_float3', data_float3
                    ) order by data_int2 desc
                ) items from grouped group by data_int1
                order by latest desc";
        }
        $query .= " limit $limit offset $offset";

        eZDebug::writeDebug($query, __METHOD__);
        $tasks = eZDB::instance()->arrayQuery($query);

        $results = [];
        if ($groupByObjectId) {
            foreach ($tasks as $task) {
                $items = json_decode($task['items'], true);
                $task['items'] = [];
                foreach ($items as $item) {
                    $task['items'][] = self::serialize($item);
                }
                $results[] = $task;
            }
        } else {
            foreach ($tasks as $task) {
                $results[] = self::serialize($task);
            }
        }

        return $results;
    }

    public static function fetchCount($filters = [], $groupByObjectId = true): int
    {
        $conditionsString = self::parseFiltersToSqlConditions($filters);
        $query = '';
        if ($groupByObjectId) {
            $query .= 'select count(distinct ezcollab_item.data_int1)';
        } else {
            $query = 'select count(*)';
        }
        $query .= " from ezcollab_item 
                full join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1)
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation' 
                $conditionsString";
        eZDebug::writeDebug($query, __METHOD__);
        $tasks = eZDB::instance()->arrayQuery($query);

        return (int)$tasks[0]['count'];
    }

    public static function fetchFacets($filters = []): array
    {
        $conditionsString = self::parseFiltersToSqlConditions($filters);
        $query = "select distinct ezcollab_item.data_float3 as assignment, ezcollab_item.data_text1 as classidentifier, ezcollab_item.data_int3 as status
                from ezcollab_item 
                full join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1)
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation' 
                $conditionsString";
        eZDebug::writeDebug($query, __METHOD__);
        $facets = eZDB::instance()->arrayQuery($query);

        return [
            'assignment' => array_unique(array_column($facets, 'assignment')),
            'classIdentifier' => array_unique(array_column($facets, 'classidentifier')),
            'status' => array_unique(array_column($facets, 'status')),
        ];
    }

    private static function parseFiltersToSqlConditions(array $filters): string
    {
        $conditions = [];
        if (!empty($filters['assignment'])) {
            $conditions[] = 'ezcollab_item.data_float3 = ' . (int)$filters['assignment'];
        }
        if (!empty($filters['creator'])) {
            $conditions[] = 'ezcollab_item.data_float2 = ' . (int)$filters['creator'];
        }
        if (isset($filters['status']) && $filters['status'] > -1) {
            if ($filters['status'] === ModerationHandler::STATUS_UNREAD){
                $conditions[] = 'ezcollab_item.id in ('. ModerationMessage::unreadApprovalIdQuery() .')';
            }else {
                $conditions[] = 'ezcollab_item.data_int3 = ' . (int)$filters['status'];
            }
        }
        if (!empty($filters['classIdentifier'])) {
            $conditions[] = "ezcollab_item.data_text1 = '" . eZDB::instance()->escapeString(
                    $filters['classIdentifier']
                ) . "'";
        }

        return !empty($conditions) ? ' and ' . implode(' and ', $conditions) : '';
    }

    public static function fetchPendingCountByObjectIdAndLocale(int $objectId, string $locale): int
    {
        $pending = ModerationHandler::STATUS_PENDING;
        $tasks = eZDB::instance()->arrayQuery(
            "select ezcollab_item.*, ezworkflow_process.id as workflow_process_id from ezcollab_item 
                join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1) 
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation'
                and ezcollab_item.data_int1 = $objectId
                AND ezcollab_item.data_text3 = '$locale'
                and ezcollab_item.data_int3 = $pending"
        );

        return count($tasks);
    }

    public static function fetchPendingCountByMainAssignmentIdAndLocale(int $mainAssignmentId, string $locale): int
    {
        $pending = ModerationHandler::STATUS_PENDING;
        $tasks = eZDB::instance()->arrayQuery(
            "select ezcollab_item.*, ezworkflow_process.id as workflow_process_id from ezcollab_item 
                join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1)
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation'
                and ezcollab_item.data_float3 = $mainAssignmentId
                AND ezcollab_item.data_text3 = '$locale'
                and ezcollab_item.data_int3 = $pending"
        );

        return count($tasks);
    }

    public static function fetchByProcessId(int $processId): ?ModerationApproval
    {
        $task = eZDB::instance()->arrayQuery(
            "select ezcollab_item.*, ezworkflow_process.id as workflow_process_id from ezcollab_item 
                join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1)
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation' 
                and ezapprove_items.workflow_process_id = $processId"
        );

        if (isset($task[0])) {
            return self::serialize($task[0]);
        }

        return null;
    }

    public static function fetchByContentObjectVersionId(int $contentObjectVersionId): ?ModerationApproval
    {
        $task = eZDB::instance()->arrayQuery(
            "select ezcollab_item.*, ezworkflow_process.id as workflow_process_id from ezcollab_item 
                full join ezapprove_items on (ezapprove_items.collaboration_id = ezcollab_item.id)
                join ezcontentobject on (ezcontentobject.id = ezcollab_item.data_int1) 
                join ezcontentobject_version on (ezcontentobject_version.id = ezcollab_item.data_int2)
                full join ezworkflow_process on (ezapprove_items.workflow_process_id = ezworkflow_process.id)
                where ezcollab_item.type_identifier = 'ocmoderation' 
                and ezcollab_item.data_int2 =  $contentObjectVersionId"
        );

        if (isset($task[0])) {
            return self::serialize($task[0]);
        }

        return null;
    }

    public static function fetchStatusByContentObjectVersionId(int $contentObjectVersionId): int
    {
        $task = eZDB::instance()->arrayQuery(
            "select ezcollab_item.data_int3 from ezcollab_item                 
                where ezcollab_item.type_identifier = 'ocmoderation' 
                and ezcollab_item.data_int2 =  $contentObjectVersionId"
        );

        if (isset($task[0])) {
            return (int)$task[0]['data_int3'];
        }

        return 100;
    }

    public static function create(ModerationApproval $moderationApproval): ModerationApproval
    {
        eZDB::instance()->begin();
        $collaborationItem = eZCollaborationItem::create('ocmoderation', (int)$moderationApproval->authorId);
        $collaborationItem->setAttribute('data_int1', (int)$moderationApproval->contentObjectId);
        $collaborationItem->setAttribute('data_int2', (int)$moderationApproval->contentObjectVersionId);
        $collaborationItem->setAttribute('data_int3', $moderationApproval->status);
        $collaborationItem->setAttribute('data_text1', $moderationApproval->classIdentifier);
        $collaborationItem->setAttribute('data_text3', $moderationApproval->contentObjectVersionLanguage);
        $collaborationItem->setAttribute('data_text2', $moderationApproval->title);
        $collaborationItem->setAttribute('data_float2', (int)$moderationApproval->authorId);
        $collaborationItem->setAttribute('data_float3', (int)$moderationApproval->mainAssignmentId);
        $collaborationItem->setAttribute('status', eZCollaborationItem::STATUS_ACTIVE);
        $collaborationItem->setAttribute('modified', time());
        $collaborationItem->store();

        $processId = (int)$moderationApproval->processId;
        $collaborationId = (int)$collaborationItem->attribute('id');
        eZDB::instance()->query(
            "INSERT INTO ezapprove_items( workflow_process_id, collaboration_id ) VALUES($processId,$collaborationId)"
        );
        $moderationApproval->id = $collaborationId;
        $moderationApproval->createdAt = (int)$collaborationItem->attribute('created');
        eZDB::instance()->commit();

        return $moderationApproval;
    }

    public static function updateStatus(ModerationApproval $moderationApproval)
    {
        $status = $moderationApproval->status;
        $active = eZCollaborationItem::STATUS_ACTIVE;
        $inactive = eZCollaborationItem::STATUS_INACTIVE;
        $timestamp = time();
        $query = "UPDATE ezcollab_item SET data_int3 = $status, status = $inactive, modified = $timestamp 
                     WHERE type_identifier = 'ocmoderation' 
                       AND data_int1 = $moderationApproval->contentObjectId 
                       AND data_int2 = $moderationApproval->contentObjectVersionId 
                       AND data_text3 = '$moderationApproval->contentObjectVersionLanguage'
                       AND status = $active";
        eZDB::instance()->query($query);
        if ($moderationApproval->status === ModerationHandler::STATUS_REFUSED) {
            $contentVersion = eZContentObjectVersion::fetch($moderationApproval->contentObjectVersionId);
            if ($contentVersion) {
                $contentVersion->setAttribute('status', eZContentObjectVersion::STATUS_ARCHIVED);
                $contentVersion->sync();
            }
        }
    }

    public static function deleteByProcessId(int $processId): void
    {
        eZDB::instance()->begin();
        $collaborations = eZDB::instance()->arrayQuery(
            "DELETE FROM ezapprove_items 
                WHERE workflow_process_id = $processId 
                RETURNING collaboration_id"
        );
        eZDB::instance()->query("DELETE FROM ezworkflow_process WHERE id = $processId");
        $sqlCondition = eZDB::instance()->generateSQLINStatement(
            array_column($collaborations, 'collaboration_id'),
            'id',
            false,
            true,
            'int'
        );
        eZDB::instance()->query(
            "DELETE FROM ezcollab_item WHERE $sqlCondition"
        );
        eZDB::instance()->commit();
    }

    public static function cleanByContentObjectIdAndVersion(
        int $contentObjectId,
        int $validVersion,
        string $locale
    ): void {
        $validVersionObject = eZContentObjectVersion::fetch($validVersion);
        if ($validVersionObject instanceof eZContentObjectVersion) {
            eZDB::instance()->begin();
            $refused = ModerationHandler::STATUS_REFUSED;
            $active = eZCollaborationItem::STATUS_ACTIVE;
            $inactive = eZCollaborationItem::STATUS_INACTIVE;
            $timestamp = time();
            $query = "UPDATE ezcollab_item SET data_int3 = $refused, status = $inactive, modified = $timestamp 
                     WHERE type_identifier = 'ocmoderation' 
                       AND data_int1 = $contentObjectId 
                       AND data_int2 != $validVersion 
                       AND data_text3 = '$locale'
                       AND status = $active
                     RETURNING id, data_int1, data_int2";
            $versions = eZDB::instance()->arrayQuery($query);
            foreach ($versions as $version) {
                $contentVersion = eZContentObjectVersion::fetch((int)$version['data_int2']);
                if ($contentVersion instanceof eZContentObjectVersion
                    && $contentVersion->attribute('status') == eZContentObjectVersion::STATUS_PENDING) {
                    $contentVersion->setAttribute('status', eZContentObjectVersion::STATUS_ARCHIVED);
                    $contentVersion->sync();
                    $approval = new ModerationApproval();
                    $approval->id = (int)$version['id'];
                    $approval->contentObjectId = (int)$version['data_int1'];
                    ModerationMessage::createAuditOnArchived($approval, (int)$validVersionObject->attribute('version'));
                }
            }
            $processes = eZDB::instance()->arrayQuery(
                "DELETE FROM ezapprove_items 
                WHERE collaboration_id in 
                  (SELECT id FROM ezcollab_item 
                    WHERE type_identifier = 'ocmoderation'
                    AND data_text3 = '$locale' 
                    AND data_int1 = $contentObjectId)
                RETURNING workflow_process_id"
            );
            if (count($processes)) {
                $sqlCondition = eZDB::instance()->generateSQLINStatement(
                    array_column($processes, 'workflow_process_id'),
                    'id',
                    false,
                    true,
                    'int'
                );
                eZDB::instance()->query(
                    "DELETE FROM ezworkflow_process WHERE $sqlCondition"
                );
            }
            eZDB::instance()->commit();
        }
    }

    private static function serialize(array $item): ModerationApproval
    {
        $instance = new self;
        $instance->id = (int)$item['id'];
        $instance->contentObjectId = (int)$item['data_int1'];
        $instance->contentObjectVersionId = (int)$item['data_int2'];
        $instance->contentObjectVersionLanguage = (string)$item['data_text3'];
        $instance->status = (int)$item['data_int3'];
        $instance->classIdentifier = $item['data_text1'];
        $instance->title = $item['data_text2'];
        $instance->createdAt = (int)$item['created'];
        $instance->authorId = (int)$item['data_float2'];
        $instance->processId = (int)$item['workflow_process_id'];
        $instance->mainAssignmentId = (int)$item['data_float3'];

        return $instance;
    }

    public function attributes(): array
    {
        $vars = array_keys(get_object_vars($this));
        $vars[] = 'is_author';
        $vars[] = 'author';
        $vars[] = 'contentclass';
        $vars[] = 'object';
        $vars[] = 'can_edit';
        $vars[] = 'version';
        $vars[] = 'history';
        $vars[] = 'comments_count';
        $vars[] = 'has_concurrent_pending';

        return $vars;
    }

    public function hasAttribute($key): bool
    {
        return in_array($key, $this->attributes());
    }

    public function attribute($key)
    {
        if (property_exists($this, $key)) {
            return $this->$key;
        }

        if (!isset($this->attributes[$key])) {
            switch ($key) {
                case 'is_author':
                    $this->attributes[$key] = $this->authorId == eZUser::currentUser()->id();
                    break;
                case 'author':
                    $this->attributes[$key] = eZUser::fetch($this->authorId);
                    break;
                case 'contentclass':
                    $this->attributes[$key] = eZContentClass::fetchByIdentifier($this->classIdentifier);
                    break;
                case 'object':
                    $this->attributes[$key] = eZContentObject::fetch($this->contentObjectId);
                    break;
                case 'can_edit':
                    $this->attributes[$key] = eZContentObject::fetch($this->contentObjectId)
                        && eZContentObject::fetch($this->contentObjectId)->canEdit();
                    break;
                case 'version':
                    $this->attributes[$key] = $this->contentObjectVersionId ?
                        eZContentObjectVersion::fetch($this->contentObjectVersionId) : false;
                    break;
                case 'history':
                    $this->attributes[$key] = ModerationMessage::fetchByApprovalId($this->id);
                    break;
                case 'comments_count':
                    $this->attributes[$key] = ModerationMessage::fetchCountByApprovalId($this->id, [ModerationMessage::TYPE_COMMENT]);
                    break;
                case 'has_concurrent_pending':
                    $this->attributes[$key] = self::fetchPendingCountByObjectIdAndLocale($this->contentObjectId, $this->contentObjectVersionLanguage) > 1;
                    break;
                default:
                    eZDebug::writeNotice("Attribute $key does not exist", get_called_class());
                    $this->attributes[$key] = false;
            }
        }

        return $this->attributes[$key];
    }

    public static function cleanup(): void
    {
        eZDB::instance()->query(
            "delete from ezcollab_item where ezcollab_item.type_identifier = 'ocmoderation' and data_int2 not in (select id from ezcontentobject_version)"
        );
        eZDB::instance()->query(
            "delete from ezapprove_items where workflow_process_id not in (select id from ezworkflow_process)"
        );
        eZDB::instance()->query(
            "delete from ezcollab_simple_message where data_int1 not in (select id from ezcollab_item where ezcollab_item.type_identifier = 'ocmoderation') and message_type like 'ocmoderation_%'"
        );
        eZDB::instance()->query(
            "delete from ezcollab_item_status where collaboration_id not in (select id from ezcollab_item)"
        );
    }
}