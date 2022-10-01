{def $ordinamento = 'name'}
{if $node.sort_array[0][0]|eq('priority')}
    {set $ordinamento = 'priority'}
{elseif $node.sort_array[0][0]|eq('published')}
    {set $ordinamento = 'pubblicato'}
{elseif $node.sort_array[0][0]|eq('modified')}
    {set $ordinamento = 'modificato'}
{/if}
{include uri='design:zone/default.tpl' zones=array(hash('blocks', array(page_block(
    '',
    "ListaAutomatica",
    "lista_card_teaser",
    hash(
        "limite", "9",
        "elementi_per_riga", "3",
        "includi_classi", "",
        "escludi_classi", "",
        "ordinamento", $ordinamento,
        "state_id", "",
        "topic_node_id", "",
        "color_style", "",
        "container_style", "",
        "node_id", $node.node_id
    )
))))}
{undef $ordinamento}