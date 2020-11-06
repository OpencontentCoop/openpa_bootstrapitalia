{def $factories = ezini( 'AvailableFactories', 'Identifiers', 'editorialstuff.ini' )}
{if count($factories)}
    <div class="my-3 p-3 bg-white rounded shadow-sm">
        <h4 class="border-bottom border-gray pb-2 mb-0">{'Collaborative content management'|i18n('editorialstuff/dashboard')}</h4>
        <div class="table-responsive">
        <table class="table table-striped table-condensed" cellpadding="0" cellspacing="0" border="0">
            {foreach $factories as $factory}
                {def $name = $factory}
                {if ezini_hasvariable( $factory, 'Name', 'editorialstuff.ini' )}
                    {set $name = ezini( $factory, 'Name', 'editorialstuff.ini' )}
                {/if}
                {def $show = true()}
                {if ezini_hasvariable( $factory, 'CreationRepositoryNode', 'editorialstuff.ini' )}
                    {def $creationRepositoryNode = fetch(content, node, hash(node_id, ezini( $factory, 'CreationRepositoryNode', 'editorialstuff.ini' )))}
                    {if $creationRepositoryNode.can_create|not()}
                        {set $show = false()}
                    {/if}
                    {undef $creationRepositoryNode}
                {/if}
                {if $show}
                <tr>
                    <td width="1">
                        <a class="btn btn-primary btn-md" href="{concat('editorialstuff/dashboard/',$factory)|ezurl(no)}">
                            <strong>{$name|wash()}</strong>
                        </a>
                    </td>
                    <td>
                        {if ezini_hasvariable( $factory, 'Description', 'editorialstuff.ini' )}
                            {ezini( $factory, 'Description', 'editorialstuff.ini' )}
                        {/if}
                    </td>
                </tr>
                {/if}
                {undef $name $show}
            {/foreach}
        </table>
        </div>
    </div>
{/if}