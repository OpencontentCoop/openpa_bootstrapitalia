{def $openpa = object_handler($node)}
{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}
{if ezini('ExtensionSettings', 'ActiveAccessExtensions')|contains('octranslate')}
{include uri="design:parts/auto_translation_alert.tpl"}
{/if}
{if $openpa.content_trasparenza.use_custom_template}
    {include uri="design:openpa/full/_custom_trasparenza.tpl"}
{else}
    {include uri=$openpa.control_template.full}
{/if}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and(openpaini('GeneralSettings','Valuation', 1), $node.class_identifier|ne('valuation'))}
    {ezpagedata_set('show_valuation', true())}
{/if}
{ezpagedata_set('opengraph', $openpa.opengraph.generate_data)}

{def $easyontology = class_extra_parameters($node.object.class_identifier, 'easyontology')}
{if and($easyontology, $easyontology.enabled, $easyontology.easyontology|ne(''))}
    {def $jsonld = $node.contentobject_id|easyontology_to_json($easyontology.easyontology)}
    {if $jsonld}<script data-element="metatag" type="application/ld+json">{$jsonld}</script>{/if}
{/if}

{if $node.object.state_identifier_array|contains('opencity_lock/locked')}
    {ezpagedata_set('is_opencity_locked', true())}
{/if}

{undef $openpa}