<div class="it-list-wrapper">
    <ul class="it-list">
    {foreach $items as $child}
        <li>
            {if and(object_handler($child).content_link.is_node_link|not(), $child.can_edit)}
                <a class="float-right" href="{$child.url_alias|ezurl(no)}"><i aria-hidden="true" class="fa fa-wrench"></i></a>
            {/if}
            {node_view_gui content_node=$child
                           view=text_linked
                           show_icon=true()
                           a_class='list-item'
                           icon_wrap_start='<div class="it-rounded-icon">'
                           icon_class='icon icon-dark'
                           icon_wrap_end='</div>'
                           text_wrap_start='<div class="it-right-zone"><span>'
                           text_wrap_end='</span></div>'}
        </li>
    {/foreach}
    </ul>
</div>