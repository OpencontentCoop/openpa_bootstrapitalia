{if and(
    fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' )),
    $current_user.is_logged_in,
    array('edit', 'browse')|contains($ui_context)|not()
)}
    <script>{literal}
    $(document).ready(function(){
        $('#toolbar').load($.ez.url+'call/openpaajax::loadWebsiteToolbar::{/literal}{if is_set($module_result.content_info.node_id)}{$module_result.content_info.node_id|int()}{else}0{/if}{literal}', null, function(response){
            $('body').addClass('fixed-wt');
            //load chosen in class list
            $("#ezwt-create").chosen({width:"300px !important"});
            $('#toolbar').trigger('ezwt-loaded');
            $('#dropdownNewsletter[data-current_node]').on('click', function () {
            let container = $(this).parent()
            let currentNodeId = $(this).data('current_node')
            let currentObjectId = $(this).data('current_object')
            let currentLocationsId = $(this).data('current_locations').toString().split('-').map(Number)
            let addLabel = container.find('[data-add_label]')
            let addTemplate = container.find('[data-add_tpl]')
            let alreadyExistsTemplate = container.find('[data-already_exists_tpl]')
            let divider = container.find('[data-divider]')
            container.find('.cloned').remove()
            addLabel.addClass('d-none')
            divider.addClass('d-none')
            $.ez('newsletter::getDraftEditions', null, function (response) {
              if(response.editions.length > 0){
                addLabel.removeClass('d-none')
                divider.removeClass('d-none')
                $.each(response.editions, function (){
                  if ($.inArray(this.node_id, currentLocationsId) < 0){
                    let item = addTemplate
                      .clone()
                      .removeAttr('data-add_tpl')
                      .removeClass('d-none')
                      .addClass('cloned')
                      .insertAfter(addLabel)
                    item.find('span.edition-name').html(this.name+' ('+this.list+')')
                    let aElem = item.find('a[data-href]');
                    let link = aElem.data('href')
                    link = link.replace('_currentObjectId', currentObjectId)
                    link = link.replace('_editionNodeId', this.node_id)
                    aElem.attr('href', link)
                  }else{
                    alreadyExistsTemplate
                      .clone()
                      .removeAttr('data-already_exists_tpl')
                      .removeClass('d-none')
                      .addClass('cloned')
                      .insertAfter(addLabel)
                      .find('span.edition-name').html(this.name+' ('+this.list+')')
                  }
                })
              }
            })
          })
            {/literal}{if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}{literal}
            window.announcekit = (window.announcekit || { queue: [], on: function(n, x) { window.announcekit.queue.push([n, x]); }, push: function(x) { window.announcekit.queue.push(x); } });
            window.announcekit.push({
                "widget": "https://announcekit.app/widgets/v2/{/literal}{openpaini('GeneralSettings', 'AnnounceKit')}{literal}",
                "selector": ".announcekit-widget",
                "name": "announcekit",
                "lang": "it"
            })
            window.announcekit.on("widget-unread", function({ widget, unread }) {
                var badge = $('#announce-news .badge');
                if (unread === 0) badge.hide();
                else badge.show().html(unread);
            })
            $('#announce-news').on('click', function (e) {
                announcekit.widget$announcekit.open();
                e.preventDefault();
            });
            {/literal}{/if}{literal}
        });
    });
    {/literal}</script>
    {if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}
    <script async src="https://cdn.announcekit.app/widget-v2.js"></script>
    {/if}
{/if}