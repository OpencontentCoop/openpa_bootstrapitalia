{def $openpa = object_handler($node)}
{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}
{include uri=$openpa.control_template.full}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{if and(fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' ) ), module_params().function_name|ne('versionview'))}
    {include uri='design:parts/load_website_toolbar.tpl' current_user=fetch(user, current_user)}
{/if}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and( openpaini('GeneralSettings','valutation', 1), $homepage.node_id|ne($node.node_id), $node.class_identifier|ne('frontpage'), $node.class_identifier|ne('homepage') ) }
    {include name=valuation node_id=$node.node_id uri='design:openpa/valuation.tpl'}
{/if}
{ezpagedata_set('opengraph', $openpa.opengraph.generate_data)}

{def $easyontology = class_extra_parameters($node.object.class_identifier, 'easyontology')}
{if and($easyontology, $easyontology.enabled, $easyontology.easyontology|ne(''))}
    {def $jsonld = $node.contentobject_id|easyontology_to_json($easyontology.easyontology)}
    {if $jsonld}<script type="application/ld+json">{$jsonld}</script>{/if}
{/if}

{undef $openpa}