{def $do_show = cond($attribute.data_int|eq(1), true(), false())}
{if and($do_show|not(), $attribute.object.data_map.cost_notes.has_content|not(), $attribute.object.data_map.has_offer.has_content|not(), is_set($confirmpublish)|not())}
    {set $do_show = true()}
{/if}

{if $do_show}
	<div class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
            <div class="card-body">                              
                <h3 class="h5 card-title big-heading">{'FREE'|i18n('bootstrapitalia')}</h3>
                <p class="mt-4">{'Free admission for all attendees'|i18n('bootstrapitalia')}</p>
            </div>
      </div>
{/if}