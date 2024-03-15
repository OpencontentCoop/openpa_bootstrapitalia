{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
{def $homepage = fetch('openpa', 'homepage')}
{def $has_managed = cond(or($node|has_attribute('managed_by_area'), $node|has_attribute('managed_by_political_body'), $node|has_attribute('help')), true(), false())}

<div class="it-hero-wrapper it-wrapped-container" id="main-container">

    {if $node|has_attribute('image')}
        <div class="img-responsive-wrapper">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {attribute_view_gui attribute=$node|attribute('image') image_class=reference}
                </div>
            </div>
        </div>
    {/if}

    <div class="container">
        <div class="row">
            <div class="col-12 drop-shadow">
                <div class="it-hero-card it-hero-bottom-overlapping rounded px-lg-5 py-4 py-lg-5">
                    <div class="row justify-content-center">
                        <div class="col-12">
                            <div class="cmp-breadcrumbs mt-0" role="navigation">
                                <nav class="breadcrumb-container" aria-label="breadcrumb">
                                    <ol class="breadcrumb p-0" data-element="breadcrumb">
                                        {foreach $node.path as $item}
                                            <li class="breadcrumb-item">
                                                <a href="{$item.url_alias|ezurl(no)}">{$item.name|wash()}</a>
                                                <span class="separator">/</span>
                                            </li>
                                        {/foreach}
                                        <li class="breadcrumb-item active" aria-current="page">
                                            {$node.name|wash()}
                                        </li>
                                    </ol>
                                </nav>
                            </div>
                        </div>
                    </div>
                    <div class="row sport-wrapper justify-content-between mt-lg-2">
                        <div class="col-12{if $has_managed} col-lg-5 pl-lg-5{else} col-lg-10 pl-lg-10{/if}">
                            <h1 class="mb-3">{$node.name|wash()}</h1>
                            <div class="u-main-black text-secondary mb-5">
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            </div>
                            {if and( $node.children_count, $node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1) )}
                                <div class="mt-4">
                                    {foreach $node.children as $child}
                                        {if topic_has_contents($child.contentobject_id)}
                                        <a class="text-decoration-none text-nowrap d-inline-block " href="{$child.url_alias|ezurl(no)}"><div class="chip chip-simple chip-{if $child.object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$child.name|wash()}</span></div></a>
                                        {/if}
                                    {/foreach}
                                </div>
                            {/if}
                        </div>
                        {if $has_managed}
                        <div class="col-12 col-lg-5">
                            <div class="card-wrapper card-column">
                                <h3 class="title-xsmall-semi-bold text-secondary">Questo argomento è gestito da:</h3>
                                {if $node|has_attribute('managed_by_area')}
                                    {foreach $node|attribute('managed_by_area').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                                {if $node|has_attribute('managed_by_political_body')}
                                    {foreach $node|attribute('managed_by_political_body').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                                {if $node|has_attribute('help')}
                                    {foreach $node|attribute('help').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                            </div>
                        </div>
                        {/if}
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

{if $node|has_attribute('layout')}
    <div style="min-height: 80px">
        {attribute_view_gui attribute=$node|attribute('layout')}
        {include uri='design:bridge/openagenda/embed_remote_contents.tpl'}
    </div>
{else}
    {def $blocks = array()}
    {def $has_first_block = false()}

    {def $root_news = 'news'|node_id_from_object_remote_id()}
    {def $news_count = api_search(concat('classes [article] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' and subtree [', $root_news, '] limit 1')).totalCount}
    {if $news_count|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'News'|i18n('bootstrapitalia/menu'),
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "article",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", $root_news,
                "show_all_link", "1",
                "show_all_text", 'All news'|i18n('bootstrapitalia'),
                "loading_count", $news_count
            )
        ))}
        {undef $is_first_block}
    {/if}
    {undef $root_news $news_count}

    {def $root_management = 'management'|node_id_from_object_remote_id()}
    {def $management_count = api_search(concat('classes [public_person,private_organization,organization] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, '  and subtree [', $root_management, '] limit 1')).totalCount}
    {if $management_count|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            'Administration'|i18n('bootstrapitalia/menu'),
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "public_person,private_organization,organization",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", $root_management,
                "show_all_link", "1",
                "show_all_text", 'The whole administration'|i18n( 'bootstrapitalia' ),
                "loading_count", $management_count
            )
        ))}
    {/if}
    {undef $root_management $management_count}

    {def $root_services = 'all-services'|node_id_from_object_remote_id()}
    {def $services_count = api_search(concat('classes [public_service] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' and subtree [', $root_services, '] limit 1')).totalCount}
    {if $services_count|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'Services'|i18n('bootstrapitalia/menu'),
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "public_service",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", $root_services,
                "show_all_link", "1",
                "show_all_text", 'All the services'|i18n( 'bootstrapitalia' ),
                "loading_count", $services_count
            )
        ))}
        {undef $is_first_block $services_count}
    {/if}
    {undef $root_services}

    {def $root_docs = 'cb945b1cdaad4412faaa3a64f7cdd065'|node_id_from_object_remote_id()}
    {def $docs_count = api_search(concat('classes [document] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, '  and subtree [', $root_docs, '] limit 1')).totalCount}
    {if $docs_count|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'Documents'|i18n('bootstrapitalia/menu'),
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "document",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", $root_docs,
                "show_all_link", "1",
                "show_all_text", "All documents"|i18n( 'bootstrapitalia' ),
                "loading_count", $docs_count
            )
        ))}
        {undef $is_first_block $docs_count}
    {/if}
    {undef $root_docs}

    {*if and($node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1), fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('topic') ) ))|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            "",
            "ListaAutomatica",
            "lista_card_alt",
            hash(
                "limite", "30",
                "elementi_per_riga", "3",
                "includi_classi", "topic",
                "escludi_classi", "",
                "ordinamento", "name",
                "state_id", "",
                "topic_node_id", "",
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "livello_profondita", 1,
                "node_id", $node.node_id
            )
        ))}
        {undef $is_first_block}
    {/if*}

    {def $openagenda_next_events = openagenda_next_events($node.object)}
    {if $openagenda_next_events.is_enabled}
        {set $blocks = $blocks|append(page_block(
            $openagenda_next_events.view.block_name,
            $openagenda_next_events.view.block_type,
            $openagenda_next_events.view.block_view,
            $openagenda_next_events.view.parameters
        ))}
    {/if}

    {if $blocks|count()}
        {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
    {else}
        <section class="page-topic section section-muted section-inset-shadow pb-5" id=""></section>
    {/if}

{/if}
