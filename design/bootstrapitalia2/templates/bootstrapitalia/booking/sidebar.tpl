<div class="col-12 col-lg-3 d-lg-block mb-4 d-none">
    <div class="cmp-navscroll sticky-top" aria-labelledby="accordion-title-one">
        <nav class="navbar it-navscroll-wrapper navbar-expand-lg" aria-label="INFORMAZIONI RICHIESTE" data-bs-navscroll="">
            <div class="navbar-custom" id="navbarNavProgress-{$step.id|wash()}">
                <div class="menu-wrapper">
                    <div class="link-list-wrapper">
                        <div class="accordion">
                            <div class="accordion-item">
                                <span class="accordion-header" id="accordion-{$step.id|wash()}">
                                    <button class="accordion-button pb-10 px-3" type="button" data-bs-toggle="collapse"
                                            data-bs-target="#collapse-{$step.id|wash()}" aria-expanded="true" aria-controls="collapse-{$step.id|wash()}">
                                        {'INFORMATION REQUIRED'|i18n('bootstrapitalia/booking')}
                                        {display_icon('it-expand', 'svg', 'icon icon-xs right')}
                                    </button>
                                </span>
                                <div class="progress">
                                    <div class="progress-bar it-navscroll-progressbar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div id="collapse-{$step.id|wash()}" class="accordion-collapse collapse show" role="region"
                                     aria-labelledby="accordion-{$step.id|wash()}">
                                    <div class="accordion-body">
                                        <ul class="link-list" data-element="page-index">
                                            {foreach $step.required as $item}
                                                <li class="nav-item">
                                                    <a class="nav-link" href="#{$item.id|wash()}">
                                                        <span class="title-medium">{$item.title|wash()}</span>
                                                    </a>
                                                </li>
                                            {/foreach}
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    </div>
</div>