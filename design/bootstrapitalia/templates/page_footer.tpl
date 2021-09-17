<footer class="it-footer" id="footer">
    {def $openpa_valuation = fetch(content, object, hash(remote_id, 'openpa-valuation'))}
    {if and(or( and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation), openpacontext().is_search_page ),$openpa_valuation, $openpa_valuation.can_read)}
        {include uri='design:openpa/valuation.tpl' openpa_valuation=$openpa_valuation}
    {/if}

    <div class="it-footer-main">
        <h3 class="sr-only d-none">{'Site map'|i18n('design/ocbootstrap/pagelayout')}</h3>
        <div class="container">
            <section>
                <div class="row clearfix">
                    <div class="col-sm-12">
                        {include uri='design:logo.tpl'}
                    </div>
                </div>
            </section>

            {def $show_footer_menu = true()}
            {if $pagedata.homepage|has_attribute('hide_footer_menu')}
                {set $show_footer_menu = cond($pagedata.homepage|attribute('hide_footer_menu').data_int|eq(1), false(), true())}
            {/if}

            {if $show_footer_menu}
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
            {/if}

            {def $has_newsletter = cond(and(ezmodule('newsletter','subscribe'), has_newsletter()), true(), false())
                 $has_social = cond(or(
                        is_set($pagedata.contacts.facebook),
                        is_set($pagedata.contacts.twitter),
                        is_set($pagedata.contacts.linkedin),
                        is_set($pagedata.contacts.instagram),
                        is_set($pagedata.contacts.youtube)
                    ), true(), false())}

            <section{if $show_footer_menu} class="py-4 border-white border-top"{/if}>
                <div class="row">

                    {def $footer_notes = fetch( 'openpa', 'footer_notes' )}
                    {if $footer_notes}
                    <div class="col pb-2">
                        <h4>
                            <span>
                                {if $pagedata.homepage|has_attribute('footer_info_label')}
                                    {$pagedata.homepage|attribute('footer_info_label').content|wash()}
                                {else}
                                    {'Informations'|i18n('openpa/footer')}
                                {/if}
                            </span>
                        </h4>
                        {attribute_view_gui attribute=$footer_notes}
                        {undef $footer_notes}
                    </div>
                    {/if}
                    
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

            {undef $has_newsletter $has_social $show_footer_menu}

        </div>
    </div>
    <div class="it-footer-small-prints clearfix">
        <h3 class="text-white sr-only d-none">{'Links'|i18n('openpa/footer')}</h3>
        <div class="container">
            {def $footer_links = fetch( 'openpa', 'footer_links' )}
            <ul class="it-footer-small-prints-list list-inline mb-0 d-flex flex-column flex-md-row">
                {foreach $footer_links as $item}
                <li class="list-inline-item">{node_view_gui content_node=$item view=text_linked}</li>
                {/foreach}
                {if and($openpa_valuation, $openpa_valuation.can_read)}
                    <li class="list-inline-item">{node_view_gui content_node=$openpa_valuation.main_node view=text_linked}</li>
                {/if}
            </ul>
            {undef $footer_links}
        </div>
    </div>
    {include uri='design:footer/copyright.tpl'}
</footer>


<a href="#" aria-hidden="true" data-attribute="back-to-top" class="back-to-top shadow" aria-label="{'back to top'|i18n('openpa/footer')}">
    {display_icon('it-arrow-up', 'svg', 'icon icon-light')}
</a>
