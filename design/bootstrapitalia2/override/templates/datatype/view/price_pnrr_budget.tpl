<p class="lead">{$attribute.content.inc_vat_price|l10n( currency )}</p>
{if and(is_set($attribute.object.data_map.mission.content.tags[0]), $attribute.object.data_map.mission.content.tags[0].parent.remote_id|eq('projects_tools_pnrr'))}
    <img class="img-full w-25 h-auto  me-5" src="{concat('images/assets/fundedbytheeu/',ezini('RegionalSettings', 'Locale'),'.png')|ezdesign( 'no' )}"
         title="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}"
         alt="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}" />
{/if}
{if $attribute.object|has_attribute('logos')}
    {foreach $attribute.object|attribute('logos').content.relation_list as $index => $item}
        {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
        {if and($object.can_read, $object|has_attribute( 'image' ))}
                {attribute_view_gui attribute=$object|attribute( 'image' ) image_class=medium image_css_class='img-full w-25 h-auto me-5'}
        {/if}
        {undef $object}
    {/foreach}
{/if}