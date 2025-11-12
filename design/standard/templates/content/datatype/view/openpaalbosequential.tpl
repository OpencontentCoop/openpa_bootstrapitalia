{if $attribute.content|ne('')}
  <p>
      {if $attribute.content|eq('pending')}
        <em>{'Il numero progressivo sarà assegnato alla pubblicazione'|i18n('bootstrapitalia/albo_pretorio')}</em>
      {else}
          {$attribute.content|wash()}
      {/if}
  </p>
{/if}