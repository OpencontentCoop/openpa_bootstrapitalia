{def $openpa = object_handler($node)}
{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}
{include uri=$openpa.control_template.full}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and(openpaini('GeneralSettings','Valuation', 1), $homepage.node_id|ne($node.node_id), $node.class_identifier|ne('valuation'))}
    {ezpagedata_set('show_valuation', true())}
{/if}
{ezpagedata_set('opengraph', $openpa.opengraph.generate_data)}

{def $easyontology = class_extra_parameters($node.object.class_identifier, 'easyontology')}
{if and($easyontology, $easyontology.enabled, $easyontology.easyontology|ne(''))}
    {def $jsonld = $node.contentobject_id|easyontology_to_json($easyontology.easyontology)}
    {if $jsonld}<script type="application/ld+json">{$jsonld}</script>{/if}
{/if}

{undef $openpa}

{*if and(ezpreference('smart_edit'), $node.object.can_create, $node.object.can_edit)}
	
	{include uri='design:load_ocopendata_forms.tpl'}
	
	<script>{literal}
	$(document).ready(function(){
	    $('#toolbar').on('ezwt-loaded', function(){
		    $(document).on('click', 'button.btn-create[name="NewButton"]', function(e){
		        var classId = $("#ezwt-create").chosen().val();
		        var classIdentifier = $('option[value="'+classId+'"]').data('class');
		        var parentId = $('#ezwt-parent').val();	        
		        
		        $('#relation-form').opendataFormCreate(
		            {
		                'class': classIdentifier,
		                'parent': parentId
		            },
		            {
		                onBeforeCreate: function () {$('#relation-modal').modal('show');},
		                onSuccess: function (data) {
		                    $('#relation-modal').modal('hide');	                    
		                    window.location.replace("/openpa/object/"+data.content.metadata.id);
		                },
		                connector: 'essential'
		            }            
		        );
		        e.preventDefault();
		    });
	    });	    
	});
	{/literal}</script>

{/if*}