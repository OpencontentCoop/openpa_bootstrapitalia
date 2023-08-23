{def $openpa = object_handler($node)}
{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}
{include uri=$openpa.control_template.full}

{def $homepage = fetch('openpa', 'homepage')}

{if and($homepage.node_id|ne($node.node_id),array('image', 'gallery')|contains($node.class_identifier)|not())}
    {include uri=$openpa.content_attachment.template}
    {include uri=$openpa.content_gallery.template}
{/if}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}


{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and(openpaini('GeneralSettings','Valuation', 1), $homepage.node_id|ne($node.node_id), $node.class_identifier|ne('valuation'))}
    {ezpagedata_set('show_valuation', true())}
{/if}
{*{ezpagedata_set('opengraph', $openpa.opengraph.generate_data)}*}

{if $openpa.control_area_tematica.is_area_tematica}
    {ezpagedata_set('is_area_tematica', $openpa.control_area_tematica.area_tematica.contentobject_id)}
{/if}

{def $easyontology = class_extra_parameters($node.object.class_identifier, 'easyontology')}
{if and($easyontology, $easyontology.enabled, $easyontology.easyontology|ne(''))}
    {def $jsonld = $node.contentobject_id|easyontology_to_json($easyontology.easyontology)}
    {if $jsonld}<script type="application/ld+json">{$jsonld}</script>{/if}
{/if}

{undef $openpa}
