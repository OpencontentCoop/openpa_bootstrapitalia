<div class="link-list-wrapper">
    <ul class="link-list">
    {foreach $items as $child}
        <li>
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