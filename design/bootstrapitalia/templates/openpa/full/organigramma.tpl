{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h2 class="h4 py-2">{$node|attribute('short_title').content|wash()}</h2>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

            {def $organigramma = organigramma()}
            <div class="org-chart">
                <ul>
                    <li>
                        {include level=0 uri='design:openpa/full/parts/organigramma_item.tpl' item=$organigramma name=organigramma_item current_id=0}
                    </li>
                </ul>
            </div>

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

{run-once}
{literal}
<style>
    .org-chart li {
        list-style-type: none;
        margin: 0;
        padding: 15px 5px 0 5px;
        position: relative
    }

    .org-chart li::before,
    .org-chart li::after {
        content: '';
        left: -20px;
        position: absolute;
        right: auto
    }

    .org-chart li::before {
        border-left: 2px solid #000;
        bottom: 50px;
        height: 100%;
        top: 0;
        width: 1px
    }

    .org-chart li::after {
        border-top: 2px solid #000;
        height: 20px;
        top: 35px;
        width: 25px
    }

    .org-chart li span {
        -moz-border-radius: 5px;
        -webkit-border-radius: 5px;
        border: 2px solid #000;
        border-radius: 3px;
        display: inline-block;
        padding: 8px 16px;
        text-decoration: none;
        cursor: pointer;
    }

    .org-chart > ul > li::before,
    .org-chart > ul > li::after {
        border: 0
    }

    .org-chart li:last-child::before {
        height: 37px
    }

    .org-chart li span:hover {
        background: #eee;
    }
</style>
{/literal}
{/run-once}
