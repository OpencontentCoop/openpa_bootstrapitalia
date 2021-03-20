{if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) )}
<li>
    <a class="list-item left-icon"
       href="{'/openpa/refreshmenu/'|ezurl(no)}"
       title="Aggiorna i menu">
        <i aria-hidden="true" class="fa fa-bars"></i>
        Rigenera menu
    </a>
</li>
{/if}
