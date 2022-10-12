{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
*}

{if $handler.enabled}
    <div class="row easyontology-select-preview ">
        <select class="easyontology-select form-control"
                name="extra_handler_{$handler.identifier}[class][{$class.identifier}][easyontology]">
            <option></option>
            {foreach $handler.easyontology_list as $easyontology}
                <option value="{$easyontology.slug}" {if $handler.easyontology|eq( $easyontology.slug )}selected="selected"{/if}>
                    {$easyontology.name|wash( xhtml )} - {$easyontology.slug}
                </option>
            {/foreach}
        </select>
    </div>
{/if}