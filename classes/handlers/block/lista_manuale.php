<?php

class OpenPABootstrapItaliaBlockHandlerListaManuale extends OpenPABlockHandler
{
    private static $cache = [];

    protected function run()
    {
        if (!isset(self::$cache[$this->currentBlock->id()])) {
            $this->data['fetch_parameters'] = array();
            $this->data['content'] = $this->currentBlock->attribute('valid_nodes');
            $this->data['has_content'] = count($this->currentBlock->attribute('valid_nodes')) > 0;
            $this->data['root_node'] = (isset($this->data['content'][0]) && $this->data['content'][0] instanceof eZContentObjectTreeNode) ? $this->data['content'][0]->attribute('parent') : null;
            self::$cache[$this->currentBlock->id()] = $this->data;
        } else {
            $this->data = self::$cache[$this->currentBlock->id()];
        }
    }
}