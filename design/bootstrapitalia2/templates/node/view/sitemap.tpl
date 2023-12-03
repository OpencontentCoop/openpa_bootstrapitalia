{ezpagedata_set( 'show_path', false() )}

{def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}
{def $homepage = fetch('openpa', 'homepage')}
{def $topics = fetch(content, object, hash(remote_id, 'topics'))
     $topic_list = cond($topics, tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu')), array())}
{def $pagedata = openpapagedata()}
{def $footer_links = fetch( 'openpa', 'footer_links' )}

<div class="row">
    <div class="col offset-lg-2">
        <div class="org-chart">
    <ul>
        <li>
            <a href="/">
                <span>
                    {$homepage.name|wash()}
                </span>
            </a>
            <ul>
                {foreach $top_menu_node_ids as $id}
                {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
                {if $tree_menu.item.internal}
                    {def $href = $tree_menu.item.url|ezurl(no)}
                {else}
                    {def $href = $tree_menu.item.url}
                {/if}
                <li>
                    <a href="{$href}">
                        <span>
                            {$tree_menu.item.name|wash()}
                        </span>
                    </a>
                    {if $tree_menu.has_children}
                        <ul>
                        {foreach $tree_menu.children as $tree_menu_child}
                            {if $tree_menu_child.item.internal}
                                {def $tree_menu_child_href = $tree_menu_child.item.url|ezurl(no)}
                            {else}
                                {def $tree_menu_child_href = $tree_menu_child.item.url}
                            {/if}
                            <li>
                                <a href="{$tree_menu_child_href}">
                                    <span>
                                        {$tree_menu_child.item.name|wash()}
                                    </span>
                                </a>
                            </li>
                            {undef $tree_menu_child_href}
                        {/foreach}
                        </ul>
                    {/if}
                </li>
                {undef $tree_menu $href}
                {/foreach}
                <li>
                    <a href="{$topics.main_node.url_alias|ezurl(no)}"><span>{$topics.name|wash()}</span></a>
                    <ul>
                        {foreach $topic_list.children as $child}
                            <li>
                                <a href="{$child.item.url|ezurl(no)}"><span>{$child.item.name|wash()}</span></a>
                            </li>
                        {/foreach}
                    </ul>
                </li>
                {def $faq_system = fetch(content, object, hash(remote_id, 'faq_system'))}
                {if $faq_system}
                    <li>
                        <a href="{object_handler($faq_system).content_link.full_link}" data-element="faq">
                            <span>{'Read the FAQ'|i18n('bootstrapitalia')}</span>
                        </a>
                    </li>
                {/if}
                {undef $faq_system}
                {if openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled')}
                <li>
                    <a href="{if is_set($pagedata.contacts['link_assistenza'])}{$pagedata.contacts['link_assistenza']|wash()}{else}{'richiedi_assistenza'|ezurl(no)}{/if}" data-element="contacts">
                        <span>{'Request assistance'|i18n('bootstrapitalia')}</span>
                    </a>
                </li>
                <li>
                    <a href="{if is_set($pagedata.contacts['numero_verde'])}{$pagedata.contacts['numero_verde']|wash()}{else}{$pagedata.contacts['telefono']|wash()}{/if}">
                        <span>{'Call the municipality'|i18n('bootstrapitalia')}</span>
                    </a>
                </li>
                <li>
                    <a href="{if is_set($pagedata.contacts['link_prenotazione_appuntamento'])}{$pagedata.contacts['link_prenotazione_appuntamento']|wash()}{else}{'prenota_appuntamento'|ezurl(no)}{/if}" data-element="appointment-booking">
                        <span>{'Book an appointment'|i18n('bootstrapitalia')}</span>
                    </a>
                </li>
                <li>
                    <a data-element="report-inefficiency" href="{if is_set($pagedata.contacts['link_segnalazione_disservizio'])}{$pagedata.contacts['link_segnalazione_disservizio']|wash()}{else}{'segnala_disservizio'|ezurl(no)}{/if}">
                        <span>{'Report a disservice'|i18n('bootstrapitalia')}</span>
                    </a>
                </li>
                {/if}
                {foreach $footer_links as $item}
                    <li>{node_view_gui content_node=$item view=text_linked span_class='fm'}</li>
                {/foreach}
            </ul>
        </li>
    </ul>

</div>
    </div>
</div>
{literal}
    <style>
        .org-chart li {
            list-style-type: none;
            margin: 0;
            padding: 15px 5px 0 30px;
            position: relative
        }

        .org-chart li::before,
        .org-chart li::after {
            content: '';
            left: -20px;
            position: absolute;
            right: auto
        }

        .org-chart li::before {
            border-left: 2px solid #000;
            bottom: 50px;
            height: 100%;
            top: 0;
            width: 1px
        }

        .org-chart li::after {
            border-top: 2px solid #000;
            height: 20px;
            top: 43px;
            width: 50px
        }

        .org-chart li span {
            -moz-border-radius: 5px;
            -webkit-border-radius: 5px;
            border: 2px solid #000;
            border-radius: 3px;
            display: inline-block;
            padding: 8px 16px;
            text-decoration: none;
            cursor: pointer;
            min-width: 150px;
            text-align: center;
            font-size: 1.3em;
        }

        .org-chart > ul > li::before,
        .org-chart > ul > li::after {
            border: 0
        }

        .org-chart li:last-child::before {
            height: 45px
        }

        .org-chart li span:hover {
            background: #eee;
        }

        .org-chart li > ul {
            padding-left: 100px !important
        }

    </style>
{/literal}
