{ezpagedata_set( 'has_container', true() )}

{def $parent = $node.parent}
{if $openpa.event_link.has_public_event_typology}
    {def $keyword = $openpa.event_link.has_public_event_typology.keyword|wash()}
    {ezpagedata_set( 'current_content_tagged_keyword', $keyword )}
    {ezpagedata_set( 'current_content_tagged_keyword_url', concat($parent.url_alias, '/(view)/', $keyword|urlencode()))}
    {undef $keyword}
{/if}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {attribute_view_gui attribute=$node|attribute('event_abstract')}

            {if openagenda_is_enabled()}
                <div class="my-5">
                    <a href="{openagenda_is_enabled()}/openpa/object/{$node.object.remote_id}" class="btn btn-primary btn-icon p-2 px-3 mobile-full">
                        {display_icon('it-calendar', 'svg', 'icon icon-white icon-lg')}
                        <span class="px-2">{'Discover the details of the event on'|i18n('bootstrapitalia')}<br />{openagenda_name()}</span>
                    </a>
                </div>
            {/if}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            <div class="mt-4 mb-4">
                {if $openpa.event_link.topic}
                    <div class="row">
                        <span class="mb-2 small">{'Topics'|i18n('bootstrapitalia')}</span>
                    </div>
                    <ul class="d-flex flex-wrap gap-1 mb-2">
                        <li>
                            <a class="chip chip-simple chip-primary"
                               href="{$openpa.event_link.topic.main_node.url_alias|ezurl(no)}">
                                <span class="chip-label text-nowrap">{$openpa.event_link.topic.name|wash()}</span>
                            </a>
                        </li>
                    </ul>
                {elseif $openpa.event_link.topic_name}
                    <div class="row">
                        <span class="mb-2 small">{'Topics'|i18n('bootstrapitalia')}</span>
                    </div>
                    <ul class="d-flex flex-wrap gap-1 mb-2">
                        <li>
                            <span class="chip chip-simple chip-primary">
                                <span class="chip-label text-nowrap">{$openpa.event_link.topic_name|wash()}</span>
                            </span>
                        </li>
                    </ul>
                {/if}
                {if $openpa.event_link.has_public_event_typology}
                    <div class="row">
                        <span class="mb-2 small">{$node|attribute('virtual_has_public_event_typology').contentclass_attribute_name}</span>
                    </div>
                    <ul class="d-flex flex-wrap gap-1 mb-2">
                        <li class="chip chip-simple chip-primary">
                            <span class="chip-label text-nowrap">
                                {$openpa.event_link.has_public_event_typology.keyword|wash()}
                            </span>
                        </li>
                    </ul>
                {elseif $openpa.event_link.has_public_event_typology_name}
                    <div class="row">
                        <span class="mb-2 small">{$node|attribute('virtual_has_public_event_typology').contentclass_attribute_name}</span>
                    </div>
                    <ul class="d-flex flex-wrap gap-1 mb-2">
                        <li class="chip chip-simple chip-primary">
                            <span class="chip-label text-nowrap">
                                {$openpa.event_link.has_public_event_typology_name|wash()}
                            </span>
                        </li>
                    </ul>
                {/if}
            </div>
        </div>
    </div>
</section>

{if $openpa.event_link.image}
<div class="container-fluid my-3">
    <div class="row">
        <figure class="figure px-0{if image_class_and_style($openpa.event_link.image.width, $openpa.event_link.image.height).can_enlarge} img-full {/if} d-block text-center" xmlns="http://www.w3.org/1999/html">
            <img class="{image_class_and_style($openpa.event_link.image.width, $openpa.event_link.image.height).css_class}"
                 style="{image_class_and_style($openpa.event_link.image.width, $openpa.event_link.image.height).inline_style}"
                 src="{$openpa.event_link.image.url}"
                 alt="{$node.name|wash()}" />
            {if or($openpa.event_link.image.author, $openpa.event_link.image.license)}
            <figcaption class="figure-caption text-center pt-3">
                <span>
                    {if $openpa.event_link.image.author}
                    &copy; {$openpa.event_link.image.author|wash()} -
                    {/if}
                    {if $openpa.event_link.image.license}
                    {$openpa.event_link.image.license|wash()}
                    {/if}
                </span>
            </figcaption>
            {/if}
        </figure>
    </div>
</div>
{/if}

<section class="container">
    {def $attribute_group = class_extra_parameters('event', 'attribute_group')
         $show = array(
            'a_chi_e_rivolto',
            'luogo',
            'date_e_orari',
            'costi',
            'contatti'
         )
         $summary_text = 'Table of contents'|i18n('bootstrapitalia')
         $close_text = 'Close'|i18n('bootstrapitalia')
    }

    <div class="row border-top border-light row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="cmp-navscroll sticky-top" aria-labelledby="accordion-title-one" data-bs-toggle="sticky" data-bs-stackable="true">
                <nav class="navbar it-navscroll-wrapper navbar-expand-lg" data-bs-navscroll="">
                    <div class="navbar-custom" id="navbarNavProgress">
                        <div class="menu-wrapper">
                            <div class="link-list-wrapper">
                                <div class="accordion">
                                    <div class="accordion-item">
                                      <span class="accordion-header" id="accordion-title-one">
                                        <button class="accordion-button pb-10 px-3 text-uppercase" type="button"
                                                data-bs-toggle="collapse"
                                                data-bs-target="#collapse-one" aria-expanded="true"
                                                aria-controls="collapse-one"
                                                data-focus-mouse="false">
                                            {$summary_text|wash()}
                                            {display_icon('it-expand', 'svg', 'icon icon-xs right')}
                                        </button>
                                      </span>
                                        <div class="progress">
                                            <div class="progress-bar it-navscroll-progressbar" role="progressbar"
                                                 aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"
                                                 style="width: 0;"></div>
                                        </div>
                                        <div id="collapse-one" class="accordion-collapse collapse show" role="region" aria-labelledby="accordion-title-one">
                                            <div class="accordion-body">
                                                <ul class="link-list" data-element="page-index">
                                                    {foreach $attribute_group.group_list as $slug => $title}
                                                        {if $show|contains($slug)|not()}{skip}{/if}
                                                        <li class="nav-item">
                                                            <a class="nav-link{if $slug|eq('a_chi_e_rivolto')} active{/if}" href="#{$slug|wash()}">
                                                                <span class="title-medium">{$title|wash()}</span>
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
        </aside>
        <section class="col-lg-8 border-light it-page-sections-container">
            {foreach $attribute_group.group_list as $slug => $title}
                {if $show|contains($slug)|not()}{skip}{/if}
                <article id="{$slug|wash()}" class="it-page-section anchor-offset">
                    <h2 class="my-3">{$title|wash()}</h2>
                    {switch match=$slug}
                    {case match='a_chi_e_rivolto'}
                        <div class="richtext-wrapper lora">
                            {attribute_view_gui attribute=$node|attribute('about_target_audience')}
                        </div>
                    {/case}
                    {case match='luogo'}
                        {def $markers = array()}
                        {if $openpa.event_link.takes_place_in}
                            <div class="card-wrapper card-column">
                                {node_view_gui content_node=$openpa.event_link.takes_place_in.main_node view=card_teaser_info show_icon=true() image_class=large}
                            </div>
                            {set $markers = $markers|append(hash('latitude', $openpa.event_link.geo.latitude, 'longitude', $openpa.event_link.geo.longitude))}
                        {elseif $openpa.event_link.geo}
                            <div class="card-wrapper card-column">
                                <div data-object_id="2400" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3 " style="z-index: 100">
                                    <div class="card-body pe-3">
                                        <p class="card-title text-paragraph-regular-medium-semi mb-3">
                                            {$openpa.event_link.geo.name|wash()}
                                        </p>
                                        <div class="card-text u-main-black">
                                            <div class="mt-1">
                                                <a href="https://www.google.com/maps/dir/45.548598,11.546282/@45.548598,11.546282,15z?hl=it"
                                                  target="_blank"
                                                  rel="noopener noreferrer"
                                                  class="text-decoration-none">
                                                    <i aria-hidden="true" class="fa fa-map"></i> {$openpa.event_link.geo.address|wash()}
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {set $markers = $markers|append(hash('latitude', $openpa.event_link.geo.latitude, 'longitude', $openpa.event_link.geo.longitude))}
                        {/if}
                        <div class="map-wrapper map-column mt-4 mb-5">
                            <div id="relations-map-event-link" style="width: 100%; height: 400px;"></div>
                        </div>
                        {ezscript_require(array('leaflet/leaflet.0.7.2.js','leaflet/Leaflet.MakiMarkers.js', 'leaflet/leaflet.markercluster.js'))}
                        <script type="text/javascript">{literal}function drowRelationMap(id, latLngList) {
                              var map = new L.Map('relations-map-'+id);
                              map.scrollWheelZoom.disable();
                              L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                              }).addTo(map);
                              var markers = L.markerClusterGroup().addTo(map);
                              var customIcon = L.divIcon({html: '<i class="fa fa-map-marker fa-4x text-primary"></i>',iconSize: [20, 20],className: 'myDivIcon'});
                              $.each(latLngList, function () {
                                var postMarker = new L.marker(this,{icon:customIcon});
                                postMarker.addTo(markers)
                              });
                              if (markers.getLayers().length > 0) {
                                map.fitBounds(markers.getBounds());
                              }
                            }{/literal}
                            $(document).ready(function () {ldelim}drowRelationMap('event-link',[{foreach $markers as $marker}[{$marker.latitude},{$marker.longitude}]{delimiter},{/delimiter}{/foreach}]);{rdelim});
                        </script>
                    {/case}
                    {case match='date_e_orari'}
                        <div class="mb-5">
                        {attribute_view_gui attribute=$node|attribute('time_interval')}
                        </div>
                    {/case}
                    {case match='costi'}
                        {if or($node|has_attribute('cost_notes'), $openpa.event_link.has_offer|count())}
                            {if $node|has_attribute('cost_notes')}
                                <div class="richtext-wrapper lora">
                                {attribute_view_gui attribute=$node|attribute('cost_notes')}
                                </div>
                            {/if}
                            {if $openpa.event_link.has_offer|count()}
                                {foreach $openpa.event_link.has_offer as $child }
                                    <div class="card no-after border-left mt-3">
                                        <div class="card-body">
                                            {if $child.has_eligible_user|ne('')}
                                                <div class="category-top">{$child.has_eligible_user|wash()}</div>
                                            {/if}
                                            {if $child.has_currency|ne('')}
                                            <h5 class="card-title big-heading">
                                                {$child.has_currency|wash()}
                                            </h5>
                                            {/if}
                                            <p class="mt-4">{$child.description|wash()}</p>
                                            {if $child.note|ne('')}
                                                {$child.note|wash()}
                                            {/if}
                                        </div>
                                    </div>
                                {/foreach}
                            {/if}
                        {else}
                            <div class="card no-after border-left mt-3">
                                <div class="card-body">
                                    <h5 class="card-title big-heading">{'FREE'|i18n('bootstrapitalia')}</h5>
                                    <p class="mt-4">{'Free admission for all attendees'|i18n('bootstrapitalia')}</p>
                                </div>
                            </div>
                        {/if}
                    {/case}
                    {case match='contatti'}
                        {if $openpa.event_link.has_online_contact_point}
                        <div class="card-wrapper card-column my-3" data-bs-toggle="masonry">
                            {node_view_gui
                                content_node=$openpa.event_link.has_online_contact_point.main_node
                                view=card_teaser_info
                                hide_title=true()
                                attribute_index=1
                                data_element=false()
                                image_class=large}
                        </div>
                        {elseif $openpa.event_link.has_online_contact_info}
                        <div class="card-wrapper card-column my-3" data-bs-toggle="masonry">
                            <div data-object_id="3105" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
                                <div class="card-body ">
                                    <div class="card-text u-main-black">
                                        <div class="mt-1">
                                            {if $openpa.event_link.has_online_contact_info.phone}
                                                <p class="mb-2 text-truncate"><b>Tel</b><br /><a href="tel:{$openpa.event_link.has_online_contact_info.phone|wash()}">{$openpa.event_link.has_online_contact_info.phone|wash()}</a></p>
                                            {/if}
                                            {if $openpa.event_link.has_online_contact_info.email}
                                                <p class="mb-2 text-truncate"><b>Email</b><br /><a href="mailto:{$openpa.event_link.has_online_contact_info.email|wash()}">{$openpa.event_link.has_online_contact_info.email|wash()}</a></p>
                                            {/if}
                                            {if $openpa.event_link.has_online_contact_info.website}
                                                <p class="mb-2 text-truncate"><b>Web</b><br /><a href="{$openpa.event_link.has_online_contact_info.website|wash()}">{$openpa.event_link.has_online_contact_info.website|wash()}</a></p>
                                            {/if}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        {/if}
                    {/case}
                    {case}{/case}
                    {/switch}
                </article>
            {/foreach}
        </section>
    </div>

</section>

{if $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

{undef $parent}