{if is_unset( $exceeded_limit ) }
    {def $exceeded_limit=false()}
{/if}

<form action={concat($module.functions.removeobject.uri)|ezurl} method="post" name="ObjectRemove">

  <div class="warning">
      {if eq( $exceeded_limit, true() )}
        <h2>Warning:</h2>
        <p>{'The items contain more than the maximum possible nodes for subtree removal and will not be deleted. You can remove this subtree using the ezsubtreeremove.php script.'|i18n( 'design/ocbootstrap/node/removeobject' )}</p>
      {else}
        <h2>{"Are you sure you want to remove these items?"|i18n("design/ocbootstrap/node/removeobject")}</h2>
      {/if}
    <ul>
        {def $booking_alert = false()}
        {foreach $remove_list as $remove_item}
            {if and($booking_alert|not(), is_object_booking_configured($remove_item.object.id))}
                {set $booking_alert = true()}
            {/if}
            {if $remove_item.childCount|gt(0)}
              <li>{"%nodename and its %childcount children. %additionalwarning"
                  |i18n( 'design/ocbootstrap/node/removeobject',,
                  hash( '%nodename', $remove_item.nodeName,
                  '%childcount', $remove_item.childCount,
                  '%additionalwarning', $remove_item.additionalWarning ) )}</li>
            {else}
              <li>{"%nodename %additionalwarning"
                  |i18n( 'design/ocbootstrap/node/removeobject',,
                  hash( '%nodename', $remove_item.nodeName,
                  '%additionalwarning', $remove_item.additionalWarning ) )}</li>
            {/if}
        {/foreach}
    </ul>
  </div>

  {if $booking_alert}
  <div class="warning">
    Attenzione: la rimozione di una o più risorse comporta la <b>cancellazione di tutte le configurazioni di prenotazione appuntamento a essa collegate</b>
    <div class="form-check">
      <input id="confirm-remove-booking"
             class="form-check-input"
             type="checkbox"
             onclick="EnableSubmitRemove()"
             name="confirm-remove-booking" />
      <label class="form-check-label" for="confirm-remove-booking">Ho capito</label>
    </div>
  </div>
    <script>
      function EnableSubmitRemove(){ldelim}
        $('#submit-remove').prop("disabled", !$("#confirm-remove-booking").prop("checked"));
      {rdelim}
    </script>
  {/if}

    {if and( $move_to_trash_allowed, eq( $exceeded_limit, false() ) )}
      <input type="hidden" name="SupportsMoveToTrash" value="1" />
      <div class="form-check">
        <input id="check-move-to-trash"
               class="form-check-input"
               type="checkbox"
               name="MoveToTrash" value="1"
               checked="checked"/>
        <label class="form-check-label" for="check-move-to-trash">{'Move to trash'|i18n('design/ocbootstrap/node/removeobject')}</label>
      </div>
      <p>
        <strong>{"Note"|i18n("design/ocbootstrap/node/removeobject")}:</strong> {"If %trashname is checked, removed items can be found in the trash."
          |i18n( 'design/ocbootstrap/node/removeobject',,
          hash( '%trashname', concat( '<i>', 'Move to trash' | i18n( 'design/ocbootstrap/node/removeobject' ), '</i>' ) ) )}
      </p>
    {/if}


  <div class="clearfix">
      {if $exceeded_limit|not()}<input id="submit-remove" class="btn btn-danger float-right" type="submit" name="ConfirmButton" value="{"Confirm"|i18n("design/ocbootstrap/node/removeobject")}" {if $booking_alert}disabled="disabled"{/if} />{/if}
    <input class="btn btn-dark float-left" type="submit" name="CancelButton" value="{"Cancel"|i18n("design/ocbootstrap/node/removeobject")}" />
  </div>

</form>
