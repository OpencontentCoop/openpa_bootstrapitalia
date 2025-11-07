{def $publication_range = cond($archive, '', "and calendar[publication_start_time,publication_end_time] = [today,now]")}


<h1 class="my-4">
  {if $archive} Storico pubblicazioni {else}Albo pretorio {/if}
</h1>

{def $blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "datatable",
            hash(
                container_class, "",   
                "intro_text", "",
                "color_style", "",
                "container_style", "",
                "remote_url", "",
                "query", concat("classes [document] and ez_tag_ids in [", $main_tag_id, "] and subtree [",$documents_node_id,"] ", $publication_range),
                "show_grid", "0",
                "show_map", "0",
                "show_search", "0",
                "input_search_placeholder", "",
                "limit", "2",
                "items_per_row", "auto",
                "facets", "Argomenti:topics.name,Tipologia:document_type",
                "view_api", "card_teaser",
                "fields", "_link,name,document_type,publication_start_time,publication_end_time",
                "simple_geo_api", "0",
                "template", ""
            )
        ))}

{include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}

{undef $blocks }
