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
                "show_search", "",
                "limit", cond(is_set($attribute.class_content.limit), $attribute.class_content.limit, 2),
                "items_per_row", "2",
                "facets", "",
                "view_api", "card_teaser",
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
            )
        )}
{/if}