{def $user_id_list = $attribute.content}
{if count($user_id_list)}
<table class="table table-striped table-condensed">
{foreach $user_id_list as $user_id}
	<tr>
		<td style="width:50px">
			<button class="btn btn-danger btn-sm" type="submit"
                    name="CustomActionButton[{$attribute.id}_remove_user][{$user_id}]"
                    title="Remove">
                <i class="fa fa-trash"></i>
            </button>
        </td>
        <td>
        	{fetch(content,object,hash(object_id, $user_id)).name|wash()}
        </td>
    </tr>
{/foreach}
</table>
{/if}

<small class="text-muted">Attenzione: non inserire utenti che hanno già priviliegi sufficienti per accedere all'area</small>
<button class="btn btn-info btn-sm" type="submit"
        name="CustomActionButton[{$attribute.id}_browse_user]">
    <i class="fa fa-plus"></i> Aggiungi utente
</button>
