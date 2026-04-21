<li>
  <div class="list-item">
      <div class="it-right-zone">
          <div>
              <h4 class="text mb-0">
                  <a href="{concat('/prenota_appuntamento?service_id=', $service.id)|ezurl(no)}"
                     aria-label="{'Book an appointment'|i18n('bootstrapitalia')} {$service.name|wash()}">
                      {$service.name|wash()}
                  </a>
              </h4>
              <p class="small m-0">
                  {$service|attribute('abstract').content|wash()}
                  {if $service|has_attribute('produces_output')}
                      <span class="d-none">
                      {foreach $service|attribute('produces_output').content.relation_list as $item}{*
                      *}<i class="fa fa-tag"></i> {fetch(content,object,hash('object_id', $item.contentobject_id)).name|wash()}{delimiter} {/delimiter}{*
                      *}{/foreach}
                      </span>
                  {/if}
              </p>
          </div>
          <span class="it-multiple">
              <span class="metadata">
                <a href="{$service.main_node.url_alias|ezurl(no)}">
                  {'Service details'|i18n('bootstrapitalia')}
                </a>
              </span>
              <a href="{concat('/prenota_appuntamento?service_id=', $service.id)|ezurl(no)}"
                 title="{'Book an appointment'|i18n('bootstrapitalia')}"
                 aria-hidden="true">
                  {display_icon('it-arrow-right-circle', 'svg', 'icon icon-primary')}
              </a>
          </span>
      </div>
  </div>
</li>