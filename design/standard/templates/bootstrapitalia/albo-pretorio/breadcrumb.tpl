<div class="container" id="main-container">
  <div class="row justify-content-center">
    <div class="col-12 col-lg-10">
      <div class="cmp-breadcrumbs" role="navigation">
        <nav class="breadcrumb-container" aria-label="breadcrumb">
          <ol class="breadcrumb p-0" data-element="breadcrumb">
            <li class="breadcrumb-item"><a href="{'/'|ezurl(no)}">Home</a><span class="separator">/</span></li>
            {if $archive}
              <li class="breadcrumb-item">
                <a href="{'/albo_pretorio'|ezurl(no)}">Albo pretorio</a>
                <span class="separator">/</span>
              </li>
              <li class="breadcrumb-item active" aria-current="page">Storico pubblicazioni</li>
            {else}
              <li class="breadcrumb-item active" aria-current="page">Albo pretorio</li>
            {/if}
          </ol>
        </nav>
      </div>
    </div>
  </div>
</div>