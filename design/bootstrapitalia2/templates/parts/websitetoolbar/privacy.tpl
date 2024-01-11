{def $privacy_states = privacy_states()}
{if and(
    $content_object.allowed_assign_state_id_list|contains($privacy_states['privacy.private'].id),
    $content_object.state_id_array|contains($privacy_states['privacy.public'].id)
)}
    <li>
        <a href="{concat( "/bootstrapitalia/privacy/make-private/", $content_object.id )|ezurl(no)}"
                title="{'Set as private'|i18n( 'bootstrapitalia' )}">
            <i aria-hidden="true" class="fa fa-eye-slash"></i>
            <span class="toolbar-label">{'Set as private'|i18n( 'bootstrapitalia' )}</span>
        </a>
    </li>
{elseif and(
    $content_object.allowed_assign_state_id_list|contains($privacy_states['privacy.public'].id),
    $content_object.state_id_array|contains($privacy_states['privacy.private'].id)
)}
    <li>
        <a href="{concat( "/bootstrapitalia/privacy/make-public/", $content_object.id )|ezurl(no)}"
                title="{'Set as public'|i18n( 'bootstrapitalia' )}">
            <i aria-hidden="true" class="fa fa-eye"></i>
            <span class="toolbar-label">{'Set as public'|i18n( 'bootstrapitalia' )}</span>
        </a>
    </li>
{/if}
{undef $privacy_states}