{if $menu_item.item.internal}
  {def $href = $menu_item.item.url|ezurl(no)}
{else}
  {def $href = $menu_item.item.url}
{/if}

{def $is_dropdown = cond(and($show_children, $menu_item.has_children), true(), false())}
{def $count_children = count($menu_item.children)}
{def $megamenu_min_items = 12}
{def $megamenu_max_items = 18}
{def $is_megamenu = cond($count_children|gt($megamenu_min_items), true(), false())}

<li class="nav-item{if $is_dropdown} dropdown{if $is_megamenu} megamenu{/if}{/if}">
  {if $is_dropdown}
    <a
      class="nav-link dropdown-toggle px-lg-2 px-xl-3"
      href="#"
      id="mainMenu{$menu_item.item.node_id}"
      role="button"
      data-element="{$menu_item.item.remote_id}"
      data-node="{$menu_item.item.node_id}"
      data-bs-toggle="dropdown"
      aria-expanded="false">
      <span>{$menu_item.item.name|wash()}</span>
      {display_icon('it-expand', 'svg', 'icon icon-xs ms-1')}
    </a>
    <div
      class="dropdown-menu {if $is_megamenu} shadow-lg {/if}"
      role="region"
      aria-labelledby="mainMenu{$menu_item.item.node_id}">
      {if $is_megamenu}
        {if $count_children|gt($megamenu_max_items)}
          {set $count_children = $megamenu_max_items}
        {/if}
        {def $split = $count_children|div(3)|ceil()}
        <div class="megamenu pb-5 pt-3 py-lg-0">
          <div class="row">
            <div class="col-12">
              <div class="it-heading-link-wrapper">
                <a
                  class="it-heading-link"
                  data-node="{$menu_item.item.node_id}"
                  data-element="{$menu_item.item.remote_id}"
                  href="{$href}"
                  {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}>
                  {display_icon('it-arrow-right-triangle', 'svg', 'icon icon-sm me-2 mb-1')}
                  <span>{'Explore the section'|i18n('bootstrapitalia')} {$menu_item.item.name|wash()}</span>
                </a>
              </div>
              <div class="row">
                {for 0 to 2 as $counter}
                  <div class="col-12 col-lg-4">
                    <div class="link-list-wrapper">
                      <ul class="link-list">
                        {foreach $menu_item.children as $child max $split offset mul($split, $counter)}
                          {if $child.item.internal}
                            {def $child_href = $child.item.url|ezurl(no)}
                          {else}
                            {def $child_href = $child.item.url}
                          {/if}
                          <li>
                            <a
                              class="list-item dropdown-item"
                              data-node="{$child.item.node_id}"
                              {if $child.item.target}target="{$child.item.target}" {/if}
                              href="{$child_href}">
                              {display_icon('it-arrow-right-triangle', 'svg', 'icon icon-sm me-2')}
                              <span>{$child.item.name|wash()}</span>
                            </a>
                          </li>
                          {undef $child_href}
                        {/foreach}
                      </ul>
                    </div>
                  </div>
                {/for}
              </div>
            </div>
          </div>
        </div>
      {else}
        <div class="link-list-wrapper">
          <ul class="link-list">
            <li class="px-2">
              <a class="dropdown-item list-item border-bottom mb-2 ps-0 pe-2 py-2"
                 data-node="{$menu_item.item.node_id}"
                 {if $menu_item.item.target}target="{$menu_item.item.target}" {/if}
                 href="{$href}">
                {display_icon('it-arrow-right-triangle', 'svg', 'icon icon-sm me-2 mb-1')}
                <span style="font-size:1.125rem;font-weight:600">{$menu_item.item.name|wash()}</span>
              </a>
            </li>
            {foreach $menu_item.children as $child}
              {if $child.item.internal}
                {def $child_href = $child.item.url|ezurl(no)}
              {else}
                {def $child_href = $child.item.url}
              {/if}
              <li>
                <a class="dropdown-item list-item"
                  data-node="{$child.item.node_id}"
                  {if $child.item.target}target="{$child.item.target}" {/if}
                  href="{$child_href}">
                  <span>{$child.item.name|wash()}</span>
                </a>
              </li>
              {undef $child_href}
            {/foreach}
          </ul>
        </div>
      {/if}
    </div>
  {else}
    <a class="main-nav-link nav-link text-truncate"
      href="{$href}"
      id="mainMenu{$menu_item.item.node_id}"
      data-element="{$menu_item.item.remote_id}"
      data-node="{$menu_item.item.node_id}"
      {if $menu_item.item.target}target="{$menu_item.item.target}" {/if}>
      <span>{$menu_item.item.name|wash()}</span>
    </a>
  {/if}
</li>

{undef $href $is_dropdown $is_megamenu $count_children}