<div class="panel-body" style="background: #fff">

    {def $node = $post.object.main_node}
    {if is_set($view_parameters.language)}
        {set $node = fetch('content', 'node', hash('node_id', $post.object.main_node_id, 'language_code', $view_parameters.language))}
    {/if}

    {def $openpa = object_handler($node)}
    <section class="container mt-3">
        <div class="row">
            <div class="col-lg-8 px-lg-4 py-lg-2">

                <h1>{$node.name|wash()}</h1>

                {include uri='design:openpa/full/parts/main_attributes.tpl'}

                {include uri='design:openpa/full/parts/info.tpl'}

            </div>
            <div class="col-lg-3 offset-lg-1">

                {if and(is_set($factory_configuration.Translations), $factory_configuration.Translations|eq('enabled'))}
                {def $node_languages = $node.object.languages}
                <ul class="list-group">
                    {def $existing_languages = array()}
                    {foreach $node_languages as $language}
                        {if $node.object.available_languages|contains($language.locale)}
                            {set $existing_languages = $existing_languages|append($language.locale)}
                            <a class="p-2 list-group-item list-group-item-action{if $language.locale|eq($node.object.current_language)} list-group-item-success{/if}"
                               style="font-size: 16px;"
                               href="{concat( $post.editorial_url, '/(language)/', $language.locale )|ezurl(no)}">
                                <img src="{$language.locale|flag_icon}" width="18" height="12" alt="{$language.locale}" /> {$language.name|wash()}
                            </a>
                        {/if}
                    {/foreach}
                    {foreach ezini('RegionalSettings', 'SiteLanguageList') as $locale}
                        {if $existing_languages|contains($locale)|not()}
                            <li class="p-2 list-group-item list-group-item-action">
                                <form class="form-inline" method="post" action="{'/content/action'|ezurl(no)}">
                                    <input type="hidden" name="HasMainAssignment" value="1"/>
                                    <input type="hidden" name="ContentObjectID" value="{$post.object_id}"/>
                                    <input type="hidden" name="NodeID" value="{$post.object.main_node_id}"/>
                                    <input type="hidden" name="ContentNodeID" value="{$post.object.main_node_id}"/>
                                    <input type="hidden" name="ContentObjectLanguageCode" value=""/>
                                    <input type="hidden" name="RedirectIfDiscarded" value="{$post.editorial_url}" />
                                    <input type="hidden" name="RedirectURIAfterPublish" value="{$post.editorial_url}" />
                                    <button type="submit" class="btn btn-link p-0 d-block w-100 text-left text-decoration-none" name="EditButton">
                                        <i aria-hidden="true" class="fa fa-plus float-right mt-1"></i>
                                        <img src="{$locale|flag_icon}" width="18" height="12" alt="{$locale}" /> {fetch('content', 'locale', hash('locale_code', $locale)).intl_language_name|wash()}
                                    </button>
                                </form>
                            </li>
                        {/if}
                    {/foreach}
                </ul>
                {undef $node_languages $existing_languages}
                {/if}

                {include uri='design:openpa/full/parts/taxonomy.tpl'}
            </div>
        </div>
    </section>
    {include uri='design:openpa/full/parts/main_image.tpl'}

    <section class="container">
        {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object show_all_attributes=true()}
    </section>


</div>
