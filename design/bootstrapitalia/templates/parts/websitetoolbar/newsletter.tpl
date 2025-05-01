{def $newsletter_edition_hash = newsletter_edition_hash()}
{def $can_add = cond(and( $current_node|can_add_to_newsletter(true()), $newsletter_edition_hash|count()|gt(0) ), true(), false())}
<li>
    <div class="dropdown">
        <button class="btn btn-dropdown dropdown-toggle toolbar-more"
                data-current_node="{$current_node.node_id}"
                data-current_object="{$current_node.contentobject_id}"
                data-current_locations="{$current_node.object.parent_nodes|implode('-')}"
                type="button" id="dropdownNewsletter"
                data-toggle="dropdown"
                data-bs-toggle="dropdown"
                aria-haspopup="true"
                aria-expanded="false">
            <i aria-hidden="true" class="fa fa-paper-plane-o"></i>
            <span class="toolbar-label">Newsletter</span>
        </button>
        <div class="dropdown-menu" aria-labelledby="dropdownNewsletter">
            <div class="link-list-wrapper">
                <ul class="link-list">
                    <li class="d-none" data-add_label="1">
                        <h3 style="line-height: 1.25 !important;font-size:.8rem">Aggiungi alla prossima edizione:</h3>
                    </li>
                    <li class="d-none" data-add_tpl="1">
                        <a class="list-item left-icon" data-href="{'/openpa/addlocationto/_currentObjectId/_editionNodeId'|ezurl(no)}">
                            <i aria-hidden="true" class="fa fa-plus"></i> <span class="edition-name"></span>
                        </a>
                    </li>
                    <li class="d-none" data-already_exists_tpl="1">
                        <a class="list-item left-icon disabled text-light" aria-disabled="true"  href="#" style="cursor: not-allowed;">
                            <i aria-hidden="true" class="fa fa-check text-light"></i> <span class="edition-name"></span>
                        </a>
                    </li>
                    <li class="d-none" data-divider="1"><span class="divider"></span></li>
                    {if fetch( 'user', 'has_access_to', hash( 'module', 'translate', 'function', 'settings' ) )}
                        <li>
                            <a class="list-item left-icon" href="{'newsletter/index'|ezurl(no)}" title="{'Newsletter dashboard'|i18n( 'cjw_newsletter/index' )}">
                                <i aria-hidden="true" class="fa fa-gears"></i> Newsletter dashboard
                            </a>
                        </li>
                    {/if}
                </ul>
            </div>
        </div>
    </div>
</li>
{undef $newsletter_edition_hash $can_add}
