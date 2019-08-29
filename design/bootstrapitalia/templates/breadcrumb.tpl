<div class="row">
    <div class="col px-lg-4">
        <nav class="breadcrumb-container" aria-label="breadcrumb">
            <ol class="breadcrumb">
                {def $root_node_depth = cond(ezini_hasvariable( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), ezini( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), 1)}
                {def $index = 1}
                {foreach openpacontext().path_array as $path}
                    {if $index|ge($root_node_depth)}
                        {if $path.url}
                            {if $path.text|eq('Classificazioni')}{skip}{/if}
                            <li class="breadcrumb-item">
                                <a href={cond( is_set( $path.url_alias ), $path.url_alias, $path.url )|ezurl}>{$path.text|wash}</a>
                                {*if $index|lt(count(openpacontext().path_array))}<span class="separator">/</span>{/if*}
                            </li>
                        {else}
                            <li class="breadcrumb-item active" aria-current="page" style="max-width: 200px">
                                {$path.text|wash}
                                {*if $index|lt(count(openpacontext().path_array))}<span class="separator">/</span>{/if*}
                            </li>
                        {/if}
                    {/if}
                    {set $index = $index|inc()}
                {/foreach}
                {undef $root_node_depth $index}
            </ol>
        </nav>
    </div>
</div>
