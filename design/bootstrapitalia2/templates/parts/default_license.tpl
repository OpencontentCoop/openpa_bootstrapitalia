{set_defaults(hash('header_tag', 'h2'))}
<{$header_tag} class="text-black h6 my-2" data-element="legal-notes-section">
    {'License title'|i18n('bootstrapitalia')}
</{$header_tag}>
<iframe src="https://www.google.com/maps/d/embed?mid=12tNaDpu7NtI22FPflv2yMxjCk8TnajU&ehbc=2E312F&noprof=1" width="640" height="480"></iframe>
<p data-element="legal-notes-body" class="mb-2 lora">
    {'License text first'|i18n('bootstrapitalia')} <a href="https://creativecommons.org/licenses/by/4.0/legalcode.it">{'License link'|i18n('bootstrapitalia')}</a>.<br />
    {'License text second'|i18n('bootstrapitalia')}
</p>
{unset_defaults(array('header_tag'))}