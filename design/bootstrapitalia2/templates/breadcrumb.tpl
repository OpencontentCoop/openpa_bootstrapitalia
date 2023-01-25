<div class="container" {if $has_container}id="main-container"{/if}>
    <div class="row{if $has_sidemenu|not()} justify-content-center{/if}">
        <div class="{if and($has_container, $has_sidemenu|not())}col-12 {if is_set($module_result.content_info.persistent_variable.has_sidemenu)} col-lg-10{else} px-lg-4{/if}{else}col px-lg-4{/if}">
            <div class="cmp-breadcrumbs" role="navigation">
                <nav class="breadcrumb-container" aria-label="breadcrumb">
                    <ol class="breadcrumb p-0" data-element="breadcrumb">
                    {def $root_node_depth = cond(ezini_hasvariable( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), ezini( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), 1)}
                    {def $_index = 1}
                    {foreach openpacontext().path_array as $path}
                        {if $_index|ge($root_node_depth)}
                            {if $path.url}
                                {if $path.text|eq('Media')}{skip}{/if}
                                {if $path.text|eq('Classificazioni')}{skip}{/if}
                                {if $path.text|eq('Applicazioni')}{skip}{/if}
                                <li class="breadcrumb-item">
                                    <a href={cond( is_set( $path.url_alias ), $path.url_alias, $path.url )|ezurl}>{if $_index|gt(1)}<span class="separator">/</span>{/if}{$path.text|wash}</a>
                                </li>
                            {else}
                                {if is_set($module_result.content_info.persistent_variable.current_view_keywords_subtree)}
                                    {if is_set($module_result.content_info.persistent_variable.view_tag_root_node_url)}
                                        <li class="breadcrumb-item">
                                            <a href={$module_result.content_info.persistent_variable.view_tag_root_node_url|ezurl}>{if $_index|gt(1)}<span class="separator">/</span>{/if}{$path.text|wash}</a>
                                        </li>
                                    {/if}
                                    {foreach $module_result.content_info.persistent_variable.current_view_keywords_subtree as $keyword}
                                        {if and($module_result.content_info.persistent_variable.current_view_tag_keyword|ne($keyword), is_set($module_result.content_info.persistent_variable.view_tag_root_node_url))}
                                            <li class="breadcrumb-item">
                                                <a href={concat($module_result.content_info.persistent_variable.view_tag_root_node_url, '/(view)/', $keyword|wash())|ezurl}><span class="separator">/</span> {$keyword|wash}</a>
                                            </li>
                                        {else}
                                            <li class="breadcrumb-item active" aria-current="page">
                                                <span class="separator">/</span> {$keyword|wash}
                                            </li>
                                        {/if}
                                    {/foreach}
                                {elseif is_set($module_result.content_info.persistent_variable.current_view_tag_keyword)}
                                    {if is_set($module_result.content_info.persistent_variable.view_tag_root_node_url)}
                                    <li class="breadcrumb-item">
                                        <a href={$module_result.content_info.persistent_variable.view_tag_root_node_url|ezurl}>{if $_index|gt(1)}<span class="separator">/</span>{/if}{$path.text|wash}</a>
                                    </li>
                                    {/if}
                                    <li class="breadcrumb-item active" aria-current="page">
                                        {if $_index|gt(1)}<span class="separator">/</span>{/if}{$module_result.content_info.persistent_variable.current_view_tag_keyword|wash}
                                    </li>
                                {else}
                                    <li class="breadcrumb-item active" aria-current="page">
                                        {if $_index|gt(1)}<span class="separator">/</span>{/if}{$path.text|wash}
                                    </li>
                                {/if}
                            {/if}
                        {/if}
                        {set $_index = $_index|inc()}
                    {/foreach}
                    {undef $root_node_depth $_index}
                    </ol>
                </nav>
            </div>
        </div>
    </div>
</div>