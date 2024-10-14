{if $attribute.has_content}
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
                "show_search", "1",
                "limit", "5",
                "items_per_row", "1",
                "facets", "",
                "view_api", "latest_messages_item",
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
            )
        )}
{/if}