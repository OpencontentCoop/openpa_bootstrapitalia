{if $attribute.has_content}
    <div class="procedure-wrapper" id="procedure-{$attribute.id}">
        {if count($attribute.content.relation_list)|gt(1)}
        <p>
            <a href="#" data-procedure-toggle class="procedure-toggle">
              <span data-procedure-show-all>
                {'Precedure view all'|i18n('bootstrapitalia')}
                {display_icon('it-expand', 'svg', 'icon')}
              </span>
              <span data-procedure-collapse-all style="display:none">
                {'Precedure hide all'|i18n('bootstrapitalia')}
                {display_icon('it-collapse', 'svg', 'icon')}
              </span>
            </a>
        </p>
        {/if}
        {foreach $attribute.content.relation_list as $index => $item}
            {def $counter = $index|inc()}
            {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
            <div class="procedure-item">
                <div class="procedure-item-header d-flex align-items-center"
                     id="heading-{$object.id}">
                    <span class="procedure-number">{$counter}</span>
                    <span class="procedure-title lh-1">{$object.name|wash()}</span>
                </div>
                <div class="procedure-item-body">
                    <p>
                        <a href="#"
                           data-bs-toggle="collapse"
                           data-bs-target="#collapse-{$object.id}"
                           aria-expanded="false"
                           class="procedure-toggle"
                           aria-controls="collapse-{$object.id}">
                            <span data-procedure-show>
                              {'Precedure view step'|i18n('bootstrapitalia')}
                              {display_icon('it-expand', 'svg', 'icon')}
                            </span>
                            <span data-procedure-collapse style="display:none">
                              {'Precedure hide step'|i18n('bootstrapitalia')}
                              {display_icon('it-collapse', 'svg', 'icon')}
                            </span>
                        </a>
                    </p>
                    <div id="collapse-{$object.id}"
                         data-procedure
                         class="procedure-item-content richtext-wrapper collapse"
                         role="region"
                         aria-labelledby="heading-{$object.id}">

                        {def $attributes = class_extra_parameters($object.class_identifier, 'table_view')}
                        {foreach $object.data_map as $identifier => $attribute}
                            {if $attributes.show|contains($identifier)|not()}
                                {skip}
                            {/if}
                            {def $do = cond($object|has_attribute($identifier), true(), false())}
                            {if $attributes.show_empty|contains($identifier)}
                                {set $do = true()}
                            {/if}
                            {if $do}
                                <div class="mb-3">
                                {if $attributes.show_label|contains($identifier)}
                                    <h5>{$object|attribute($identifier).contentclass_attribute_name|wash()}</h5>
                                {/if}
                                {attribute_view_gui attribute=$object|attribute($identifier)
                                                    view_context=howto_step
                                                    attribute_group=false()
                                                    image_class=imagelargeoverlay
                                                    attribute_index=$index
                                                    context_class=$object.class_identifier
                                                    relation_view=banner
                                                    relation_has_wrapper=true()
                                                    show_link=true()
                                                    tag_view="chip-lg mr-2 me-2"}
                                </div>
                            {/if}
                            {undef $do}
                        {/foreach}
                        {undef $attributes}
                    </div>
                </div>
            </div>
            {undef $object $counter}
        {/foreach}
    </div>
{/if}

{run-once}
{literal}
<script>
  $(document).ready(function () {
    let wrapper = $('.procedure-wrapper')
    let showAll = wrapper.find('[data-procedure-show-all]')
    let hideAll = wrapper.find('[data-procedure-collapse-all]')
    let instances = [];
    let syncAllToggle = function () {
      if (wrapper.find('[data-procedure].show').length === instances.length) {
        showAll.hide()
        hideAll.show()
      }
      if (wrapper.find('[data-procedure].show').length === 0) {
        showAll.show()
        hideAll.hide()
      }
    }
    wrapper.find('[data-procedure]').each(function () {
      let instance = bootstrap.Collapse.getOrCreateInstance(this, {
        toggle: false
      });
      this.addEventListener('hidden.bs.collapse', event => {
        syncAllToggle()
      })
      this.addEventListener('shown.bs.collapse', event => {
        syncAllToggle()
      })
      this.addEventListener('hide.bs.collapse', event => {
        let collapse = $(event.target)
        collapse.prev().find('[data-procedure-show]').show()
        collapse.prev().find('[data-procedure-collapse]').hide()
        collapse.parents('.procedure-item').find('.procedure-item-header').removeClass('procedure-item-header-open')
      })
      this.addEventListener('show.bs.collapse', event => {
        let collapse = $(event.target)
        collapse.prev().find('[data-procedure-show]').hide()
        collapse.prev().find('[data-procedure-collapse]').show()
        collapse.parents('.procedure-item').find('.procedure-item-header').addClass('procedure-item-header-open')
      })
      instances.push(instance);
    })
    wrapper.find('[data-procedure-toggle]').on('click', function (e) {
      e.preventDefault();
      let action;
      if (showAll.is(':visible')) {
        showAll.hide()
        hideAll.show()
        action = 'show'
      } else {
        showAll.show()
        hideAll.hide()
        action = 'hide'
      }
      $.each(instances, function () {
        console.log(action, this)
        if (action === 'show') {
          this.show()
        } else {
          this.hide()
        }
      })
    })
  })
</script>
<style>
    .procedure-item-header{
        background: #f4fafb;
        font-size: 1.15em;
        padding: 0;
        font-weight: 600;
    }
    .procedure-item-header-open{
        background: var(--bs-primary);
        color: #fff
    }
    .procedure-title{
        padding: 7px 10px;
    }
    .procedure-number{
        padding: 7px 20px;
        border-right: 2px solid #fff;
    }
    .procedure-item-body{
        padding-left: 36px;
        margin-left: 27px;
        border-left: 1px solid #c5c7c9;
    }
    .procedure-toggle{
        font-size: .875em;
        text-decoration: none;
        color: var(--bs-primary);
        margin: 12px 0 20px;
        font-weight: 600;
    }
    .procedure-toggle .icon {
        width: 25px;
        height: 25px;
    }
</style>
{/literal}
{/run-once}