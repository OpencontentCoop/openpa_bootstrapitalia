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
                    {foreach $top_menu_node_ids as $id max 4}
                        {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
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

            <section class="py-4 border-white border-top">
                <div class="row">
                    <div class="col-lg-3 col-md-3 pb-2">
                        {def $footer_notes = fetch( 'openpa', 'footer_notes' )}
                        <h4><span>{'Informations'|i18n('openpa/footer')}</span></h4>
                        {attribute_view_gui attribute=$footer_notes}
                        {undef $footer_notes}
                    </div>
                    <div class="{if ezmodule('newsletter','subscribe')}col-lg-3 col-md-3{else}col-lg-6 col-md-6{/if} pb-2">
                        <h4><span>{'Contacts'|i18n('openpa/footer')}</span></h4>
                        {include uri='design:footer/contacts.tpl'}
                    </div>
                    {if ezmodule('newsletter','subscribe')}
                    <div class="col-lg-3 col-md-3 pb-2">
                        <h4><span>Newsletter</span></h4>
                        {include uri='design:footer/newsletter_subscribe.tpl'}
                    </div>
                    {/if}
                    <div class="col-lg-3 col-md-3 pb-2">
                        <h4><span>{'Follow us'|i18n('openpa/footer')}</span></h4>
                        {include uri='design:footer/social.tpl'}
                    </div>
                </div>
            </section>

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


<a href="#" aria-hidden="true" data-attribute="back-to-top" class="back-to-top back-to-top-small shadow">
    {display_icon('it-arrow-up', 'svg', 'icon icon-light')}
</a>