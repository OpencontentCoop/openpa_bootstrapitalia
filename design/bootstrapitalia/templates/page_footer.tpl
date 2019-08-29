<footer class="it-footer">
    <div class="it-footer-main">
        <div class="container">
            <section>
                <div class="row clearfix">
                    <div class="col-sm-12">
                        {include uri='design:logo.tpl'}
                    </div>
                </div>
            </section>

            {def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}
            {if count($top_menu_node_ids)|gt(0)}
            <section>
                <div class="row">
                    {foreach $top_menu_node_ids as $id}
                        {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu'))}
                        {include recursion=0
                                 name=top_menu
                                 uri='design:footer/menu_item.tpl'
                                 menu_item=$tree_menu}
                        {undef $tree_menu}
                    {/foreach}
                </div>
            </section>
            {/if}
            {undef $top_menu_node_ids}

            {def $has_newsletter = cond(and(ezmodule('newsletter','subscribe'), newsletter_edition_hash()|count()|gt(0)), true(), false())
                 $has_social = cond(or(
                        is_set($pagedata.contacts.facebook),
                        is_set($pagedata.contacts.twitter),
                        is_set($pagedata.contacts.linkedin),
                        is_set($pagedata.contacts.instagram),
                        is_set($pagedata.contacts.youtube)
                    ), true(), false())}

            <section class="py-4 border-white border-top">
                <div class="row">
                    
                    <div class="col pb-2">
                        {def $footer_notes = fetch( 'openpa', 'footer_notes' )}
                        <h4><span>{'Informations'|i18n('openpa/footer')}</span></h4>
                        {attribute_view_gui attribute=$footer_notes}
                        {undef $footer_notes}
                    </div>
                    
                    <div class="col pb-2">
                        <h4><span>{'Contacts'|i18n('openpa/footer')}</span></h4>
                        {include uri='design:footer/contacts.tpl'}
                    </div>
                    
                    {if $has_newsletter}                        
                        <div class="col pb-2">
                            <h4><span>Newsletter</span></h4>
                            {include uri='design:footer/newsletter_subscribe.tpl'}
                        </div>                        
                    {/if}
                    
                    {if $has_social}
                    <div class="col pb-2">
                        <h4><span>{'Follow us'|i18n('openpa/footer')}</span></h4>
                        {include uri='design:footer/social.tpl'}
                    </div>
                    {/if}

                </div>
            </section>

            {undef $has_newsletter $has_social}

        </div>
    </div>
    <div class="it-footer-small-prints clearfix">
        <div class="container">
            {def $footer_links = fetch( 'openpa', 'footer_links' )}
            <h3 class="sr-only">Sezione Link Utili</h3>
            <ul class="it-footer-small-prints-list list-inline mb-0 d-flex flex-column flex-md-row">
                {foreach $footer_links as $item}
                <li class="list-inline-item">{node_view_gui content_node=$item view=text_linked}</li>
                {/foreach}
            </ul>
            {undef $footer_links}
        </div>
    </div>
    {include uri='design:footer/copyright.tpl'}
</footer>


<a href="#" aria-hidden="true" data-attribute="back-to-top" class="back-to-top shadow">
    {display_icon('it-arrow-up', 'svg', 'icon icon-light')}
</a>