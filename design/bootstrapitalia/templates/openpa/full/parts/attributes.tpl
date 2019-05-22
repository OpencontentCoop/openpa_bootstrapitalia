{def $summary_text = "Indice della pagina"
     $close_text = "Chiudi"}

{def $summery_items = array(
    hash( 'slug', 'test', 'title', 'Test', 'attributes', array() ),
    hash( 'slug', 'test2', 'title', 'Test2', 'attributes', array() )
)}

<div class="container">
    <div class="row row-top-border row-column-border">
        <aside class="col-lg-3 col-md-4">
            <div class="sticky-wrapper navbar-wrapper">
                <nav class="navbar it-navscroll-wrapper navbar-expand-lg">
                    <button class="custom-navbar-toggler" type="button" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarNav">
                        <span class="it-list"></span> {$summary_text|wash()}
                    </button>
                    <div class="navbar-collapsable" id="navbarNav">
                        <div class="overlay"></div>
                        <div class="close-div sr-only">
                            <button class="btn close-menu" type="button">
                                <span class="it-close"></span> {$close_text|wash()}
                            </button>
                        </div>
                        <a class="it-back-button" href="#">
                            <svg class="icon icon-sm icon-primary align-top">
                                <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-chevron-left"></use>
                            </svg>
                            <span>{$close_text|wash()}</span>
                        </a>
                        <div class="menu-wrapper">
                            <div class="link-list-wrapper">
                                <h3 class="no_toc">{$summary_text|wash()}</h3>
                                <ul class="link-list">
                                    {foreach $summery_items as $index => $item}
                                        <li class="nav-item{if $index|eq(0)} active{/if}">
                                            <a class="nav-link{if $index|eq(0)} active{/if}" href="#{$item.slug|wash()}"><span>{$item.title|wash()}</span></a>
                                        </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>
            </div>
        </aside>
        <section class="col-lg-9 col-md-8 pt8">
            {foreach $summery_items as $index => $item}
                <article id="{$item.slug|wash()}">
                    <h4>{$item.title|wash()}</h4>
                </article>
            {/foreach}
        </section>
    </div>
</div>