<div class="row">
    <div class="col px-lg-4">
        <nav class="breadcrumb-container" aria-label="breadcrumb">
            <ol class="breadcrumb">
                {def $root_node_depth = cond(ezini_hasvariable( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), ezini( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), 1)}
                {def $_index = 1}
                {foreach openpacontext().path_array as $path}
                    {if $_index|ge($root_node_depth)}
                        {if $path.url}
                            {if $path.text|eq('Media')}{skip}{/if}
                            {if $path.text|eq('Classificazioni')}{skip}{/if}
                            {if $path.text|eq('Applicazioni')}{skip}{/if}
                            <li class="breadcrumb-item">
                                <a href={cond( is_set( $path.url_alias ), $path.url_alias, $path.url )|ezurl}>{$path.text|wash}</a>                                
                            </li>
                        {else}
                            {if is_set($module_result.content_info.persistent_variable.current_view_tag_keyword)}
                                <li class="breadcrumb-item">
                                    <a href={$module_result.content_info.persistent_variable.view_tag_root_node_url|ezurl}>{$path.text|wash}</a>                                
                                </li>
                                <li class="breadcrumb-item active" aria-current="page" style="max-width: 200px">
                                    {$module_result.content_info.persistent_variable.current_view_tag_keyword|wash}
                                </li>
                            {else}
                                <li class="breadcrumb-item active" aria-current="page" style="max-width: 200px">
                                    {$path.text|wash}
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
