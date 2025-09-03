{if $pagedata.homepage|has_attribute('notice_header_text')}
  <div class="it-header-slim-wrapper theme-light bs-is-sticky border-bottom"
    data-bs-toggle="sticky"
    style="top: 0px;">
    <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="it-header-slim-wrapper-content justify-content-center">
            <span class="fw-semibold text-secondary text-decoration-underline">
              {$pagedata.homepage|attribute('notice_header_text').content|wash( xhtml )}
            </span>
            {if $pagedata.homepage|has_attribute('notice_header_link')}
              <a href="{$pagedata.homepage|attribute('notice_header_link').content|wash( xhtml )}"
                class="fw-semibold link-primary text-nowrap d-inline-flex ms-2">
                {'Read more'|i18n('bootstrapitalia')}
              </a>
            {/if}
          </div> 
        </div>
      </div>
    </div>
  </div>
{/if}