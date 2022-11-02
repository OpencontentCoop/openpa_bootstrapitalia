{if is_set($select_blocks)}

  <div class="row">
    <div class="col-md-12">
      <h3><span>Seleziona il blocco</span></h3>
      <ul class="list-group">
        {foreach $select_blocks as $block}
          <li class="list-group-item">
            <a href="{concat('openpa/block/',$block.id)|ezurl(no)}"><strong>{$block.name}</strong> {$block.type} <small>{$block.view}</small></a>
          </li>
        {/foreach}
      </ul>
    </div>
  </div>

{else}

  <a class="btn btn-success mb-3" href="{'openpa/block/'|ezurl(no)}">Seleziona nuovo oggetto</a>

  <div class="row">
    <div class="col-md-3">
      {foreach $blocks as $AllowedType => $AllowedBlock}
        <h3 class="openpa-widget-title"><span>{$AllowedBlock.Name|wash()}</span></h3>
        <ul class="list-group">
          {foreach $AllowedBlock.ViewName as $ViewList => $ViewName}
            <li class="list-group-item">
              {if $block.view|eq($ViewList)}
                <a href="#"><strong>{$ViewName|wash()} <br /><small>{$ViewList}</small></strong></a>
              {else}
                <a href="{concat('openpa/block/',$block.id, '/', $ViewList)|ezurl(no)}">{$ViewName|wash()} <br /><small>{$ViewList}</small></a>
              {/if}
            </li>
          {/foreach}
        </ul>
      {/foreach}
    </div>

    <div class="col-md-9">
      {if $block}
      <p>
        <a id="expand" class="btn btn-default u-text-xxs"><i aria-hidden="true" class="fa fa-expand"></i></a>
        <a id="collapse" class="btn btn-default u-text-xxs"><i aria-hidden="true" class="fa fa-compress"></i></a>
      </p>

      {def $current_items_per_row = 3}
      {if and( is_set($block.custom_attributes.elementi_per_riga),
               $block.custom_attributes.elementi_per_riga|is_numeric,
               $block.custom_attributes.elementi_per_riga|gt(0),
               $block.custom_attributes.elementi_per_riga|le(6) ) }
        {set $current_items_per_row = $block.custom_attributes.elementi_per_riga}
      {elseif ezini_hasvariable( $block.type, 'ItemsPerRow', 'block.ini' )}
        {def $current_items_per_row_settings = ezini( $block.type, 'ItemsPerRow', 'block.ini' )}
        {if is_set($current_items_per_row_settings[$block.view])}
          {set $current_items_per_row = $current_items_per_row_settings[$block.view]}
        {/if}
        {undef $current_items_per_row_settings}
      {/if}

      <div class="frontpage" style="margin-top:20px;">
          {block_view_gui block=$block items_per_row=$current_items_per_row}
      </div>
    </div>
    {/if}
  </div>

  {literal}
  <script>
    $(document).ready(function(){
      var $demo = $('#demo');
      $('#expand').on('click',function(){
        var current = $demo.data('width');
        if (current < 12) {
          $demo.removeClass('col-md-'+current);
          current++;
          $demo.data('width', current);
          $demo.addClass('col-md-'+current);
          $(window).trigger('resize');

          var owl = $('#carousel_{/literal}{$block.id}{literal}');
          var owlInstance = owl.data('owlCarousel');
          if(owlInstance != null) owlInstance.reinit();

        }
      });
      $('#collapse').on('click',function(){
        var current = $demo.data('width');
        if (current > 1) {
          $demo.removeClass('col-md-'+current);
          current--;
          $demo.data('width', current);
          $demo.addClass('col-md-'+current);
          $(window).trigger('resize');

          var owl = $('#carousel_{/literal}{$block.id}{literal}');
          var owlInstance = owl.data('owlCarousel');
          if(owlInstance != null) owlInstance.reinit();

        }
      });
    });
  </script>
  {/literal}

{/if}
