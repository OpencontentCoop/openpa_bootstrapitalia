{def $factories = ezini( 'AvailableFactories', 'Identifiers', 'editorialstuff.ini' )}
{if count($factories)}
    <div class="my-3 p-3 bg-white rounded shadow-sm">
        <h6 class="border-bottom border-gray pb-2 mb-0">Dashboard di collaborazione</h6>

        <table class="table table-striped table-condensed" cellpadding="0" cellspacing="0" border="0">
            {foreach $factories as $factory}
                {def $name = $factory}
                {if ezini_hasvariable( $factory, 'Name', 'editorialstuff.ini' )}
                    {set $name = ezini( $factory, 'Name', 'editorialstuff.ini' )}
                {/if}
                <tr>
                    <td>
                        <a href="{concat('editorialstuff/dashboard/',$factory)|ezurl(no)}">
                            <strong>{$name|wash()}</strong>
                            {if ezini_hasvariable( $factory, 'Description', 'editorialstuff.ini' )}
                                - {ezini( $factory, 'Description', 'editorialstuff.ini' )}
                            {/if}
                        </a>
                    </td>
                </tr>
                {undef $name}
            {/foreach}
        </table>
    </div>
{/if}