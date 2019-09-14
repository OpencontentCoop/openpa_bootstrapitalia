<?php

class OpenPABootstrapItaliaBlockHandlerListaManuale extends OpenPABlockHandler
{

    protected function run()
    {
        $this->data['fetch_parameters'] = array();
        $this->data['content'] = $this->currentBlock->attribute( 'valid_nodes' );
        $this->data['has_content'] = count($this->currentBlock->attribute( 'valid_nodes' )) > 0;
        $this->data['root_node'] = ( $this->data['content'][0] instanceof eZContentObjectTreeNode ) ? $this->data['content'][0]->attribute( 'parent' ) : null;
    }
}