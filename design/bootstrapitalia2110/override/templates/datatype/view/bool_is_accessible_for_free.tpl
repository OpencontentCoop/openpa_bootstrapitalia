{def $do_show = cond($attribute.data_int|eq(1), true(), false())}
{if and($do_show|not(), $attribute.object.data_map.cost_notes.has_content|not(), $attribute.object.data_map.has_offer.has_content|not(), is_set($confirmpublish)|not())}
    {set $do_show = true()}
{/if}

{if $do_show}
  <p class="font-serif">{'Free admission for all attendees'|i18n('bootstrapitalia')}</p>
{/if}