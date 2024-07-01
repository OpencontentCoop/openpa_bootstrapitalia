<p class="lead">{$attribute.content.inc_vat_price|l10n( currency )}</p>
{if and(is_set($attribute.object.data_map.mission.content.tags[0]), $attribute.object.data_map.mission.content.tags[0].parent.remote_id|eq('projects_tools_pnrr'))}
    <img class="img-full w-25 h-auto" src="{concat('images/assets/fundedbytheeu/',ezini('RegionalSettings', 'Locale'),'.png')|ezdesign( 'no' )}"
         title="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}"
         alt="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}" />
{/if}
