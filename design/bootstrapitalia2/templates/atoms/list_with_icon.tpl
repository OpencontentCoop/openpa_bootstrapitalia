<ul class="link-list">
    {foreach $items as $child}
        <li>
            {if and(object_handler($child).content_link.is_node_link|not(), $child.can_edit)}
                <a class="float-right" href="{$child.url_alias|ezurl(no)}"><i aria-hidden="true" class="fa fa-wrench"></i></a>
            {/if}
            {node_view_gui content_node=$child
                                   view=text_linked
                                   show_icon=true()}
        </li>
    {/foreach}
</ul>
