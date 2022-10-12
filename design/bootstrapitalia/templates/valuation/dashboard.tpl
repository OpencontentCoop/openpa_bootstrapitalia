{ezpagedata_set('show_path', false())}
<div class="row">
    <div class="col-md-12">

        {def $recaptcha_public_key = openpa_recaptcha_public_key(3)}
        {if or($recaptcha_public_key|eq('no-public'), $recaptcha_public_key|eq(''))}
            <div class="alert alert-danger">Per attivare il form di segnalazione su ciascuna pagina è necessario <a href="{'openpa/recaptcha'|ezurl(no)}">impostare un codice Google ReCaptcha versione 3</a></div>
        {/if}


        {if is_set($collection)}

            <h3><a href={'/valuation/dashboard/'|ezurl}><i aria-hidden="true" class="fa fa-arrow-circle-left"></i></a> {'User feedbacks'|i18n("bootstrapitalia/valuation")}</h3>
            <h4>
                {'Feedback #%id'|i18n( 'bootstrapitalia/valuation',, hash( '%id', $collection.id ) )|wash}
                <small class="d-block">
                    {'Last modified'|i18n( 'design/admin/infocollector/view' )}: {$collection.created|l10n( shortdatetime )}
                    &dash; {if $collection.creator}{$collection.creator.contentobject.name|wash}{else}{'Unknown user'|i18n( 'design/admin/infocollector/view' )}{/if}
                </small>
            </h4>

            {foreach $collection.attributes as $item}
                {if $item.contentclass_attribute.identifier|eq('antispam')}{skip}{/if}
                <div class="row mt-2 pt-2 border-top">
                    <div class="col-4 font-weight-bold">{$item.contentclass_attribute_name|wash}:</div>
                    <div class="col-8">{attribute_result_gui view=info attribute=$item}</div>
                </div>
            {/foreach}

        {else}

            <div class="row mb-3">
                <div class="col">
                    <a href="{'/valuation/csv/'|ezurl(no)}" class="btn btn-info float-right"><i class="fa fa-download"></i> Download CSV</a>
                    <h3>{'User feedbacks'|i18n("bootstrapitalia/valuation")}</h3>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col">
                    <div class="p-3 text-center">
                        <p class="font-weight-bold mb-2 d-block">{'Feedbacks count'|i18n("bootstrapitalia/valuation")}</p>
                        <p class="h1 py-5"><span class="badge badge-dark bg-dark">{$collection_count}</span></p>
                    </div>
                </div>
                <div class="col">
                    <div class="p-3 text-center">
                        <p class="font-weight-bold mb-2 d-block">{'Is content useful?'|i18n("bootstrapitalia/valuation")}</p>
                        <p class="h1 py-5">
                            {foreach $useful_count as $item}
                                {if $item.data_text|eq(0)}<span class="badge badge-danger bg-danger mx-3">{'No'|i18n('design/admin/class/view')} {$item.count}</span>{/if}
                                {if $item.data_text|eq(1)}<span class="badge badge-success bg-success mx-3">{'Yes'|i18n('design/admin/class/view')} {$item.count}</span>{/if}
                            {/foreach}
                        </p>
                    </div>
                </div>
                <div class="col">
                    <div class="p-3 text-center">
                        <p class="font-weight-bold mb-2 d-block">{'Problems'|i18n("bootstrapitalia/valuation")}</p>
                        <ul class="list-group text-left mb-2">
                        {foreach $attributes.problem_type.content.options as $option}
                            <li class="list-group-item py-1 d-flex justify-content-between align-items-center">
                                {$option.name|wash()}
                                {foreach $problem_type_count as $item}
                                    {if $item.data_text|eq($option.id)}
                                        <span class="badge badge-danger bg-danger badge-pill">{$item.count}</span>
                                    {/if}
                                {/foreach}
                            </li>
                        {/foreach}
                        </ul>
                    </div>
                </div>
            </div>

            {if $collection_array|count()}
            <table class="table table-striped table-sm">
                <thead>
                <tr>
                    <th></th>
                    <th>{'Created'|i18n( 'design/admin/infocollector/collectionlist' )}</th>
                    {foreach $attributes as $identifier => $attribute}
                        {if array('useful', 'problem_type')|contains($identifier)}
                        <th>{$attribute.name|wash()}</th>
                        {/if}
                    {/foreach}
                    <th></th>
                </tr>
                </thead>
                <tbody>
                {foreach $collection_array as $collection}
                    {def $collection_attributes = $collection.attributes}
                    <tr>
                        <td><code>{$collection.id}</code></td>
                        <td>{$collection.created|l10n( shortdatetime )}</td>
                        {foreach $attributes as $identifier => $attribute}
                            {if array('useful', 'problem_type')|contains($identifier)}
                                {foreach $collection_attributes as $collection_attribute}
                                    {if $collection_attribute.contentclass_attribute_id|eq($attribute.id)}
                                        <td>{attribute_result_gui view=info attribute=$collection_attribute}</td>
                                    {/if}
                                {/foreach}
                            {/if}
                        {/foreach}
                        <td><a class="btn btn-xs btn-primary nowrap" href={concat( '/valuation/dashboard/', $collection.id )|ezurl}>{'Further details'|i18n('bootstrapitalia')}</a></td>
                    </tr>
                    {undef $collection_attributes}
                {/foreach}
                </tbody>
            </table>
            {else}
                <div class="block">
                    <p>{'No information has been collected by this object.'|i18n( 'design/admin/infocollector/collectionlist' )}</p>
                </div>
            {/if}

            <div class="context-toolbar">
                {include name=navigator
                         uri='design:navigator/google.tpl'
                         page_uri='/valuation/dashboard'
                         item_count=$collection_count
                         view_parameters=$view_parameters
                         item_limit=$limit}
            </div>
        {/if}

    </div>
</div>