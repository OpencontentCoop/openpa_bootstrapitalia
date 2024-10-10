{if and(
    fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' )),
    $current_user.is_logged_in,
    array('edit', 'browse')|contains($ui_context)|not()
)}
    <script>{literal}
      $(document).ready(function () {
        $('#toolbar').load($.ez.url + 'call/openpaajax::loadWebsiteToolbar::{/literal}{if is_set($module_result.content_info.node_id)}{$module_result.content_info.node_id|int()}{else}0{/if}{literal}', null, function (response) {
          $('body').addClass('fixed-wt');
          //load chosen in class list
          $("#ezwt-create").chosen({width: "300px !important"});
          $('#toolbar').trigger('ezwt-loaded');
          $('button[name="LockEditButton"]').on('click', function (e) {
            $('#relation-form').opendataFormEdit({
                'object': $(this).data('object')
              }, {
                onBeforeCreate: function () {
                  $('#relation-modal').modal('show');
                },
                onSuccess: function (data) {
                  $('body').css('opacity', '.3');
                  var prefix = UriPrefix === '/' ? '' : UriPrefix
                  window.location.replace(prefix+"/openpa/object/" + data.content.metadata.id);
                  $('#relation-modal').modal('hide');
                },
                connector: 'lock_edit'
              });
            e.preventDefault();
          })
          {/literal}{if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}{literal}
          window.announcekit = (window.announcekit || {
            queue: [], on: function (n, x) {
              window.announcekit.queue.push([n, x]);
            }, push: function (x) {
              window.announcekit.queue.push(x);
            }
          });
          window.announcekit.push({
            "widget": "https://announcekit.app/widgets/v2/{/literal}{openpaini('GeneralSettings', 'AnnounceKit')}{literal}",
            "selector": ".announcekit-widget",
            "name": "announcekit",
            "lang": "it"
          })
          window.announcekit.on("widget-unread", function ({widget, unread}) {
            var badge = $('#announce-news .badge');
            if (unread === 0) badge.hide();
            else badge.show().html(unread);
          })
          $('#announce-news').on('click', function (e) {
            announcekit.widget$announcekit.open();
            e.preventDefault();
          });
          {/literal}{/if}{literal}
          {/literal}{if is_approval_enabled()}{literal}
          $('#dropdownApproval').on('show.bs.dropdown', function () {
            let listItemStyle = 'max-width: 300px;overflow: hidden;text-overflow: ellipsis;'
            let placeholder = $('#approval-placeholder');
            let container = $('#approval-items');
            let counter = $('#approval-count');
            let prefix = UriPrefix === '/' ? '' : UriPrefix
            container.html('')
            placeholder.show();
            $.ez('ezjscapproval::unread', null, function (response) {
              placeholder.hide();
              if (response.content.unread.length > 0){
                $.each(response.content.unread, function (){
                  let url = prefix+'/bootstrapitalia/approval/object/'+this.object_id;
                  container.prepend(
                      $('<li><a style="'+listItemStyle+'" class="list-item left-icon" href="'+url+'"><i aria-hidden="true" class="fa fa-comment"></i> '+this.items[0].title+'</a></li>')
                  );
                })
              }
              if (response.content.pending.length > 0){
                if (response.content.unread.length > 0) {
                  container.prepend(
                      $('<li><span class="divider"></span></li>')
                  );
                }
                $.each(response.content.pending, function (){
                  let url = prefix+'/bootstrapitalia/approval/object/'+this.object_id;
                  let pendingCount = this.count > 1 ? ' ('+this.count+')' : '';
                  container.prepend(
                      $('<li><a style="'+listItemStyle+'" class="list-item left-icon" href="'+url+'"><i aria-hidden="true" class="fa fa-history text-danger"></i> '+this.items[0].title+pendingCount+'</a></li>')
                  );
                })
              }
              //counter.text(response.content.pending.length+response.content.unread.length)
            })
          })
          {/literal}{/if}{literal}
        });
      });
    {/literal}</script>
    {if openpaini('GeneralSettings', 'AnnounceKit')|ne('disabled')}
    <script async src="https://cdn.announcekit.app/widget-v2.js"></script>
    {/if}
{/if}

{if and(is_set($module_result.content_info.persistent_variable.is_opencity_locked), current_user_can_lock_edit())}
  {include uri='design:load_ocopendata_forms.tpl'}
{/if}
