{if $attribute.has_content}
    {def $filter = concat('Period'i18n('editorialstuff/dashboard'), ':time_interval,')}
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
                "show_map", "0",
                "show_search", "0",
                "limit", 1,
                "items_per_row", "1",
                "facets", $filter,
                "view_api", "card",
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
            )
        )}
    {undef $filter}
{/if}