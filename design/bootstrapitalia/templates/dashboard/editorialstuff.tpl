{def $factories = ezini( 'AvailableFactories', 'Identifiers', 'editorialstuff.ini' )}
{if count($factories)}
    <div class="my-3 p-3 bg-white rounded shadow-sm">
        <h4 class="border-bottom border-gray pb-2 mb-0">{'Collaborative content management'|i18n('editorialstuff/dashboard')}</h4>

        {if ezini_hasvariable('DashboardBlock_editorialstuff', 'IntroText', 'dashboard.ini')}
            {def $introText = ezini('DashboardBlock_editorialstuff', 'IntroText', 'dashboard.ini')|explode('|')}
            {if is_set($introText[1])}
                {def $intro_object = fetch(content, object, hash('remote_id', $introText[0]))}
                {if and($intro_object, $intro_object|has_attribute($introText[1]))}
                    <div class="lead py-2">
                        {attribute_view_gui attribute=$intro_object|attribute($introText[1])}
                    </div>
                {/if}
                {undef $intro_object}
            {else}
                <p class="lead py-2">{$introText[0]|simpletags}</p>
            {/if}
            {undef $introText}
        {/if}

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
                    <td width="1">
                        <a class="btn btn-primary btn-md text-nowrap"
                           href="{concat('editorialstuff/add/',$factory)|ezurl(no)}">
                            <i class="fa fa-plus mr-2"></i> {ezini( $factory, 'CreationButtonText', 'editorialstuff.ini' )|wash()}
                        </a>
                    </td>
                    <td>
                        {if ezini_hasvariable( $factory, 'Description', 'editorialstuff.ini' )}
                            <p>{ezini( $factory, 'Description', 'editorialstuff.ini' )|simpletags}</p>
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