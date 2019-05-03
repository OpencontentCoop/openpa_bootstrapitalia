<nav class="breadcrumb-container" aria-label="breadcrumb">
    <ol class="breadcrumb">
        {def $root_node_depth = cond(ezini_hasvariable( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), ezini( 'SiteSettings', 'RootNodeDepth', 'site.ini' ), 1)}
        {def $index = 1}
        {foreach openpacontext().path_array as $path}
            {if $index|ge($root_node_depth)}
                {if $path.url}
                    <li class="breadcrumb-item text-truncate">
                        <a href={cond( is_set( $path.url_alias ), $path.url_alias, $path.url )|ezurl}>{$path.text|wash}</a>
                        <span class="separator">/</span>
                    </li>
                {else}
                    <li class="breadcrumb-item active text-truncate" aria-current="page">
                        <a href="#">{$path.text|wash}</a>
                    </li>
                {/if}
            {/if}
            {set $index = $index|inc()}
        {/foreach}
        {undef $root_node_depth $index}
    </ol>
</nav>
