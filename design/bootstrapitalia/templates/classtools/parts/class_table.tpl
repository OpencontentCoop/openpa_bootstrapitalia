{if $class}
    <table class="table table-bordered class-{$class.identifier}{if $current.id|eq($class.id)} current{/if} collapsed"
           data-class_identifier="{$class.identifier}">
        <thead id="end-connect-{$class.identifier}">
        <tr>
            <th colspan="2" class="class-title">
                <a href={concat('classtools/relations/', $class.identifier)|ezurl}><b>{$class.name|wash()}</b></a>
                <a href="#" class="toggle" style="float: right"><i aria-hidden="true" class="fa fa-expand"></i></a>
            </th>
        </tr>
        <tr>
            <th colspan="2" class="class-info">{foreach $class.ingroup_list as $group}{$group.group_name|wash()}{delimiter}, {/delimiter}{/foreach}</th>
        </tr>
        </thead>
        <tbody>
        {foreach $class.data_map as $attribute}
            {def $css = array()}
            {if $attribute.data_type_string|eq( 'ezobjectrelationlist' )}
                {set $css = $attribute.content.class_constraint_list}
                {if $current.id|eq($class.id)}{set $css = $css|append('related')}{/if}
            {/if}

            <tr class="{$css|implode(' ')}">
                <td>
                    <span class="{$attribute.category}">
                        {$attribute.name|wash()}
                        <br /><small>{$attribute.identifier|wash()}</small>
                    </span>
                </td>
                <td style="white-space: nowrap;width: 35px">
                    {switch match=$attribute.data_type_string}
                    {case match="ezselection"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-list-ul" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezprice"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-euro" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezkeyword"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-square" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="eztags"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-tags" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezgmaplocation"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-map-marker" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezdate"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-calendar" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezdatetime"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-calendar" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="eztime"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-calendar" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezmatrix"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-table" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezxmltext"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-paragraph" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezauthor"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-id-card" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezobjectrelation"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-share" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezobjectrelationlist"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-share-alt" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezbinaryfile"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-file-o" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezimage"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-image" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezpage"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-file-image-o" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezboolean"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-check" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezuser"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-user" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezfloat"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-calculator" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezinteger"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-calculator" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezstring"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-bold" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezsrrating"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-star" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezemail"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-inbox" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezcountry"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-flag-checkered" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ezurl"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-link" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="eztext"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-file-text" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case match="ocmultibinary"}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-files-o" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {case}
                        <span class="tool" data-tip="{$attribute.data_type.information.name|wash()}"><i aria-hidden="true" class="fa fa-square" title="{$attribute.data_type.information.name|wash()}"></i></span>
                    {/case}
                    {/switch}
                    {if $attribute.is_searchable}<span class="tool" data-tip="{'Is searchable'|i18n( 'design/admin/class/view' )}"><i aria-hidden="true" class="fa fa-search"></i></span>{/if}
                    {if $attribute.is_required}<span class="tool" data-tip="{'Is required'|i18n( 'design/admin/class/view' )}"><i aria-hidden="true" class="fa fa-asterisk"></i></span>{/if}
                </td>
            </tr>
            {undef $css}
        {/foreach}
        </tbody>
    </table>
{/if}