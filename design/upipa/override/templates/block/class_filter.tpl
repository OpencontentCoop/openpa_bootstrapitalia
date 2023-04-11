{set_defaults( hash('show_title', true()) )}
{def $customs=$block.custom_attributes
	 $parent_node_id=ezini( 'NodeSettings', 'RootNode', 'content.ini' ) 
	 $filter_array=array() 
	 $class='' 
	 $sort_by=array('name', true())}

{if $customs[node_id]|gt(0)}
	{set $parent_node_id=$customs[node_id]}
	{def $parent_node=fetch(content,node,hash(node_id,$parent_node_id))}
{/if}

{if $customs[class]|ne('')}
	{set $class=$customs[class]}
{/if}

{if $class|ne('')}

    {def $nodes = fetch( content, tree, hash( parent_node_id, $parent_node_id,
                                                'sort_by', $sort_by, 'class_filter_type',
                                                'include', 'class_filter_array', array($class),
                                                'limit', 100))}

    {if $nodes|count()|gt(0)}

        <div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">

            {if and( $show_title, $block.name|ne('') )}
                <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
            {/if}
            <div class="openpa-widget-content">
                <form id="search-form-{$block.id}" action="{'redirect/redirect'|ezurl('no')}" method="post">
                    <fieldset>
                        <legend class="hide"><span>{$block.name}</span></legend>
                        <div class="border-box box-gray block-search">
                        <div class="border-tl"><div class="border-tr"><div class="border-tc"></div></div></div>
                        <div class="border-ml"><div class="border-mr"><div class="border-mc">
                        <div class="border-content">
                            <select id="redirect-{$block.name}" name="node_id">
                            {foreach $nodes as $n}
                                <option value="{$n.node_id}">{$n.name}</option>
                            {/foreach}
                            </select>
                            <input value={$customs[attribute]} name="view" type="hidden" />

                            <input id="search-button-{$block.id}" class="defaultbutton" type="submit" name="SearchButton" value="{'Search'|i18n('openpa_designitalia')}" />


                        </div>
                        </div></div></div>
                        <div class="border-bl"><div class="border-br"><div class="border-bc"></div></div></div>
                        </div>
                    </fieldset>
                </form>
            </div>
        </div>
	{/if}
{else}
    {editor_warning( "Attenzione: non hai specificato la classe nel blocco" )}
{/if}
