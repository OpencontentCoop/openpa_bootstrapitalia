<div class="Prose">
  <h4><a href="{$node.url_alias|ezurl(no)}" class="u-textClean"><i class="fa {$node|fa_class_icon( 'fa-file' )}"></i> {$node.name|wash()}</a></h4>
  <small>{$node.object.published|datetime( 'custom', '%d %F %Y' )}</small>
  
  <p>{$node|abstract()|oc_shorten(150)}</p>
    
</div>
