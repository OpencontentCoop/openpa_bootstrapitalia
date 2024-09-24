{def $object = false()
     $attribute_base='ContentObjectAttribute'
	 $attribute_id = 0
	 $priority = 100}
{if is_set( $arguments[0] )}
    {set $object = fetch( content, object, hash( object_id, $arguments[0] ))}
{/if}
{if is_set( $arguments[1] )}
    {set $attribute_id = $arguments[1]}
{/if}
{if is_set( $arguments[2] )}
    {set $priority = $arguments[2]}
{/if}

<tr>
  {* Remove. *}
  <td>
      <input type="checkbox" name="{$attribute_base}_selection[{$attribute_id}][]" value="{$object.id}" />
      <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute_id}[]" value="{$object.id}" />
  </td>

  {* Name *}
  <td>
    <div class="float-right">
    {if and($object.can_edit, $object.current.status|eq(1))}
      <a data-priority="{$priority}" data-attribute="{$attribute_id}" data-edit="{$object.id}" href="#">
        <span class="fa-stack text-info">
          <i aria-hidden="true" class="fa fa-square fa-stack-2x"></i>
          <i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i>
        </span>
      </a>
      {/if}
    </div>
  	{if $object|has_attribute( 'image' )}
  	  {attribute_view_gui attribute=$object|attribute( 'image' ) image_class=rss image_css_class='img-thumbnail' fluid=false()}
  	{/if}	
    {if ezini('RegionalSettings', 'SiteLanguageList')|count()|gt(1)}
      {foreach ezini('RegionalSettings', 'SiteLanguageList') as $locale}
          <img src="{$locale|flag_icon}" width="18" height="12" alt="{$locale}"
          {if $object.available_languages|contains($locale)|not()}style="opacity:0.2"{/if}
          />
      {/foreach}
    {/if}
    <span class="name">{$object.name|wash()}</span> <small>({$object.class_name|wash()})</small>
  </td>

  {* Section *}
  <td><small>{fetch( section, object, hash( section_id, $object.section_id ) ).name|wash()}</small></td>
				
  {* Order. *}
  <td>
    <input size="2" type="text" name="{$attribute_base}_priority[{$attribute_id}][]" value="{$priority}" />
  </td>

</tr>
