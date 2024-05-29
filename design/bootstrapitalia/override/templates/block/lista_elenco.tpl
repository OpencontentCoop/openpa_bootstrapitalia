{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}
{if $openpa.has_content}
{include uri='design:parts/block_name.tpl'}
    <div class="it-list-wrapper">
        <ul class="it-list">
        {foreach $openpa.content as $item}
            <li>
            {node_view_gui content_node=$item
               view=text_linked
               show_icon=false()
               a_class='list-item'
               add_abstract=true()
               text_wrap_start='<div class="it-right-zone"><span class="text">'
               text_wrap_end=concat('</span><svg class="icon"><use href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use></svg></div>')}
            </li>
        {/foreach}
        </ul>
    </div>
    {include uri='design:parts/block_show_all.tpl'}
{/if}
{unset_defaults(array('items_per_row'))}

{undef $openpa}