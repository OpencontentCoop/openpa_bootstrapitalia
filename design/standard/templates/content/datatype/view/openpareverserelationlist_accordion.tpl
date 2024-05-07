{def $item_count = fetch('bootstrapitalia', 'openpareverse_count', hash('attribute', $attribute))}
{if $item_count}
    {block_view_gui
        items_per_row=1
        wrapper_class=''
        container_class=''
        show_name=false()
        block=page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", fetch('bootstrapitalia', 'openpareverse_query', hash('attribute', $attribute)),
                "show_grid", "1",
                "show_map", "",
                "show_search", cond($item_count|gt(10), "1", ""),
                "limit", "20",
                "items_per_row", "1",
                "facets", "",
                "view_api", "accordion",
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", 'Search'|i18n('bootstrapitalia')
            )
        )}
{/if}