<?php

class eZTagsDescription extends eZPersistentObject
{
    /**
     * Constructor
     *
     * @param array $row
     */
    function __construct($row)
    {
        parent::eZPersistentObject($row);
    }

    /**
     * Returns eZTagsDescription object for given tag ID and locale
     *
     * @static
     *
     * @param int $tagID
     * @param string $locale
     *
     * @return eZTagsDescription|eZPersistentObject
     */
    static public function fetch($tagID, $locale)
    {
        $fetchParams = ['keyword_id' => $tagID, 'locale' => $locale];

        return parent::fetchObject(self::definition(), null, $fetchParams);
    }

    /**
     * Returns the definition array for eZTagsDescription
     *
     * @return array
     */
    static public function definition()
    {
        return [
            'fields' => [
                'keyword_id' => [
                    'name' => 'KeywordID',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true
                ],
                'description_text' => [
                    'name' => 'DescriptionText',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true
                ],
                'locale' => [
                    'name' => 'Locale',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true
                ],
            ],
            'function_attributes' => [
                'language_name' => 'languageName'
            ],
            'keys' => ['keyword_id', 'locale'],
            'class_name' => 'eZTagsDescription',
            'sort' => ['keyword_id' => 'asc', 'locale' => 'asc'],
            'name' => 'eztags_description'
        ];
    }

    /**
     * Returns eZTagsDescription list for given tag ID
     *
     * @static
     *
     * @param int $tagID
     *
     * @return eZTagsDescription[]
     */
    static public function fetchByTagID($tagID)
    {
        $tagsDescriptionList = parent::fetchObjectList(self::definition(), null, ['keyword_id' => $tagID]);

        if (is_array($tagsDescriptionList))
            return $tagsDescriptionList;

        return [];
    }

    /**
     * Returns count of eZTagsDescription objects for supplied tag ID
     *
     * @static
     *
     * @param int $tagID
     *
     * @return int
     */
    static public function fetchCountByTagID($tagID)
    {
        return parent::count(self::definition(), ['keyword_id' => (int)$tagID]);
    }

    /**
     * Returns array with language name and locale for this instance
     *
     * @return array|bool
     */
    public function languageName()
    {
        /** @var eZContentLanguage $language */
        $language = eZContentLanguage::fetchByLocale($this->attribute('locale'));

        if ($language instanceof eZContentLanguage)
            return ['locale' => $language->attribute('locale'), 'name' => $language->attribute('name')];

        return false;
    }
}
