<div class="link-list-wrapper">
    <ul class="link-list">
    {foreach $items as $child}
        <li>
            {if and(object_handler($child).content_link.is_node_link|not(), $child.can_edit)}
                <a class="float-right" href="{$child.url_alias|ezurl(no)}"><i class="fa fa-wrench"></i></a>
            {/if}
            {node_view_gui content_node=$child
                           view=text_linked
                           show_icon=true()
                           a_class='list-item'
                           text_wrap_start='<span>'
                           text_wrap_end='</span>'}
        </li>
    {/foreach}
    </ul>
</div>