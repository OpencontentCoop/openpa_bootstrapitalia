{def $publication_range = cond($archive, '', "and calendar[publication_start_time,publication_end_time] = [today,now]")}
{def $official_noticeboard_title = cond($setup_object.data_map.title.content|ne(''), $setup_object.data_map.title.content|wash(), 'Official noticeboard'|i18n('bootstrapitalia'))}
{include uri='design:bootstrapitalia/albo-pretorio/breadcrumb.tpl' archive=$archive official_noticeboard_title=$official_noticeboard_title}

<div class="container">
  <div class="row justify-content-center">
    <div class="col-12 col-lg-10">
      <div class="cmp-hero">
        <section class="it-hero-wrapper bg-white d-block">
          <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 ">
            <h1 class="text-black hero-title" data-element="page-name">{if $archive}{'Official noticeboard archive'|i18n('bootstrapitalia')}{else}{$official_noticeboard_title}{/if}</h1>
          </div>
          {if $setup_object|has_attribute('intro')}
              {attribute_view_gui attribute=$setup_object|attribute('intro')}
          {/if}
          {if $archive}
            <a class="btn btn-link p-0" href="{'/albo_pretorio'|ezurl(no)}">{'Official noticeboard'|i18n('bootstrapitalia')}</a>
          {else}
            <a class="btn btn-link p-0" href="{'/albo_pretorio/archivio'|ezurl(no)}">{'Official noticeboard archive'|i18n('bootstrapitalia')}</a>
          {/if}
        </section>
      </div>
    </div>
  </div>
</div>
{def $blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "datatable",
            hash(
                container_class, "",
                "intro_text", "",
                "color_style", "",
                "container_style", "",
                "remote_url", "",
                "query", concat("classes [document] and id_albo_pretorio != null ", $publication_range),
                "show_grid", "0",
                "show_map", "0",
                "show_search", "0",
                "input_search_placeholder", "",
                "limit", "2",
                "items_per_row", "auto",
                "facets", "Tipologia:document_type, Unità organizzativa:has_organization",
                "view_api", "card_teaser",
                "fields", "_link,id_albo_pretorio,name,document_type,publication_start_time,publication_end_time",
                "simple_geo_api", "0",
                "template", ""
            )
        ))}

{include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}

{undef $blocks $official_noticeboard_title $publication_range}
