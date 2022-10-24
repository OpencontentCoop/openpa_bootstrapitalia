<ul class="nav d-block nav-pills border-right border-primary pb-3 overflow-hidden">
    {if $views|contains('list')}
        <li class="nav-item py-3 text-center">
            <a data-toggle="tab" data-bs-toggle="tab"
               class="nav-link {if $views[0]|eq('list')}active {/if}rounded-0 dashboard-view-selector"
               href="#list">
                <i aria-hidden="true" class="fa fa-list fa-2x" aria-hidden="true"></i> <span
                    class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
            </a>
        </li>
    {/if}
    {if $views|contains('geo')}
        <li class="nav-item py-3 text-center">
            <a data-toggle="tab" data-bs-toggle="tab"
               class="nav-link {if $views[0]|eq('geo')}active {/if}rounded-0 dashboard-view-selector"
               href="#geo">
                <i aria-hidden="true" class="fa fa-map fa-2x" aria-hidden="true"></i> <span
                    class="sr-only">{'Map'|i18n('extension/ezgmaplocation/datatype')}</span>
            </a>
        </li>
    {/if}
    {if $views|contains('agenda')}
        <li class="nav-item py-3 text-center">
            <a data-toggle="tab" data-bs-toggle="tab"
               class="nav-link {if $views[0]|eq('agenda')}active {/if}rounded-0 dashboard-view-selector"
               href="#agenda">
                <i aria-hidden="true" class="fa fa-calendar fa-2x" aria-hidden="true"></i> <span
                    class="sr-only">{'Calendar'|i18n('design/ocbootstrap/blog/calendar')}</span>
            </a>
        </li>
    {/if}
</ul>
