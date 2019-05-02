{if openpacontext().canonical_url}
    {* Multiple locations, pointing Search Engines to the original *}
    <link rel="canonical" href="{openpacontext().canonical_url|ezurl('no','full')}" />
{/if}
