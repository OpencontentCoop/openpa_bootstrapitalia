<li>
  <a href="{concat('/prenota_appuntamento?service_id=', $service.id)|ezurl(no)}" class="list-item">
      <div class="it-right-zone">
              <span class="text mb-0">
                  <span>{$service.name|wash()}</span>
                  <em class="w-75">
                      {$service|attribute('abstract').content|wash()}
                      {if $service|has_attribute('produces_output')}
                          <span class="d-none">
                          {foreach $service|attribute('produces_output').content.relation_list as $item}{*
                          *}<i class="fa fa-tag"></i> {fetch(content,object,hash('object_id', $item.contentobject_id)).name|wash()}{delimiter} {/delimiter}{*
                          *}{/foreach}
                          </span>
                      {/if}
                  </em>
              </span>
          {display_icon('it-chevron-right', 'svg', 'icon')}
      </div>
  </a>
</li>