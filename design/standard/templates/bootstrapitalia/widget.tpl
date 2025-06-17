{ezpagedata_set( 'has_container', true() )}
<div class="container mb-3">
    <h1 class="mb-5">Builtin widget</h1>
    <div class="row mx-lg-n3">
        {foreach $list as $identifier => $builtin}
        <div class="col-md-4 mb-4">
            <div class="card-wrapper h-100 border border-light rounded shadow-sm cmp-list-card-img-hr">
                <div class="card rounded bg-white">
                    <div class="row g-2 g-md-0 flex-md-column">
                        <div class="card-body">
                            <h3 class="card-title">
                                {$builtin.label|i18n('bootstrapitalia/footer')}
                                <small class="d-block">{$identifier|wash()}</small>
                            </h3>
                            {if $builtin.description_list_item.is_enabled}
                                <span class="text-decoration-none text-nowrap d-inline-block"><div class="chip chip-simple bg-success"><span class="chip-label text-white">IN PRODUZIONE</span></div></span>
                            {else}
                                <span class="text-decoration-none text-nowrap d-inline-block"><div class="chip chip-simple chip-danger"><span class="chip-label">NON IN PRODUZIONE</span></div></span>
                            {/if}
                            <p class="my-3" style="font-weight: normal">{$builtin.description_list_item.text}</p>
                            {if $builtin.has_custom_config}
                                <a class="text-decoration-none text-nowrap d-block mb-2"
                                  target="_blank"
                                  rel="noopener"
                                  href="{concat('/bootstrapitalia/widget/', $identifier, '?edit')|ezurl(no)}"><div class="chip chip-simple chip-warning"><span class="chip-label">Snippet di inclusione custom</span></div>
                                </a>
                            {else}
                                <a class="d-block mb-2"
                                  href="{concat('/bootstrapitalia/widget/', $identifier, '?edit')|ezurl(no)}"
                                  target="_blank"
                                  rel="noopener">
                                  <small>Crea snippet di inclusione custom</small>
                                </a>
                            {/if}
                            <a class="text-decoration-none text-nowrap d-inline-block "
                              target="_blank"
                              rel="noopener"
                              href="{$builtin.src|wash()}">
                              <div class="chip chip-simple chip-secondary"><span class="chip-label">Sorgente JS</span></div>
                            </a>
                            <a class="text-decoration-none text-nowrap d-inline-block "
                              target="_blank"
                              rel="noopener"
                              href="{$builtin.style|wash()}">
                              <div class="chip chip-simple chip-secondary"><span class="chip-label">Sorgente CSS</span></div>
                            </a>
                            {if $builtin.service_id}
                                <span class="text-decoration-none d-inline-block" style="max-width:100%"><div class="chip chip-simple chip-info"><span class="chip-label"><strong>Service:</strong> {$builtin.service_id|wash()}</span></div></span>
                            {/if}

                            <a class="read-more"
                               href="{if $builtin.has_production_url}{$builtin.production_url|ezurl(no)}{else}{concat('/bootstrapitalia/widget/', $identifier)|ezurl(no)}{/if}"
                              target="_blank"
                              rel="noopener">
                                <span class="text">Esegui un test</span>
                                {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        {/foreach}
    </div>
</div>
{*
<small class="d-block">({$builtin.identifier|wash()}{$builtin.service_id|wash()})</small>
*}