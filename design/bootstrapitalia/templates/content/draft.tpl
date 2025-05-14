{ezpagedata_set( 'show_path',false() )}
<style>.breadcrumb-container,.cmp-breadcrumbs{ldelim}display:none{rdelim}</style>

<div class="content-draft mb-3 p-3">
    <script type="text/javascript">
        function checkAll() {ldelim}
          if (document.draftaction.selectall.value == "{'Select all'|i18n('design/ocbootstrap/content/draft')}") {ldelim}
            document.draftaction.selectall.value = "{'Deselect all'|i18n('design/ocbootstrap/content/draft')}";
            with (document.draftaction) {ldelim}
              for (var i = 0; i < elements.length; i++) {ldelim}
                if (elements[i].type == 'checkbox' && elements[i].name == 'DeleteIDArray[]')
                  elements[i].checked = true;
              {rdelim}
            {rdelim}
          {rdelim} else {ldelim}
            document.draftaction.selectall.value = "{'Select all'|i18n('design/ocbootstrap/content/draft')}";
            with (document.draftaction) {ldelim}
              for (var i = 0; i < elements.length; i++) {ldelim}
                if (elements[i].type == 'checkbox' && elements[i].name == 'DeleteIDArray[]')
                  elements[i].checked = false;
              {rdelim}
            {rdelim}
          {rdelim}
        {rdelim}
    </script>

    {def $page_limit=30
         $list_count=fetch('content','draft_count')}

    <form name="draftaction" action={concat("content/draft/")|ezurl} method="post">
        <h1 class="h3">{"My drafts"|i18n("design/ocbootstrap/content/draft")}</h1>
        {if $list_count}
            <p class="lead">
                {"These are the current objects you are working on. The drafts are owned by you and can only be seen by you.
      You can either edit the drafts or remove them if you don't need them any more."|i18n("design/ocbootstrap/content/draft")|nl2br}
            </p>
        {/if}

        {if $list_count}
            <table class="table" width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr>
                    <th></th>
                    <th>{"Name"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Class"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Section"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Version"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Language"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Last modified"|i18n("design/ocbootstrap/content/draft")}</th>
                    <th>{"Edit"|i18n("design/ocbootstrap/content/draft")}</th>
                </tr>
                {foreach fetch('content', 'draft_version_list', hash( 'limit', $page_limit, 'offset', $view_parameters.offset ) ) as $draft sequence array(bglight,bgdark) as $style}
                    <tr class="{$style}">
                        <td align="left" width="1">
                            <input type="checkbox" name="DeleteIDArray[]" value="{$draft.id}"/>
                        </td>
                        <td>
                            <a href={concat("/content/versionview/",$draft.contentobject.id,"/",$draft.version,"/")|ezurl}>{$draft.version_name|wash}</a>
                        </td>
                        <td>
                            {$draft.contentobject.content_class.name|wash}
                        </td>
                        <td>
                            {$draft.contentobject.section_id}
                        </td>
                        <td>
                            {$draft.version}
                        </td>
                        <td>
                            {$draft.initial_language.name|wash}
                        </td>
                        <td>
                            {$draft.modified|l10n(datetime)}
                        </td>
                        <td width="1">
                            <a href={concat("/content/edit/",$draft.contentobject.id,"/",$draft.version,"/")|ezurl}>
                                <span class="fa-stack">
                                  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                                  <i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                                </span>
                            </a>
                        </td>
                    </tr>
                {/foreach}
                <tr class="bgdark">
                    <td colspan="4" align="left" width="1">
                        <button class="btn btn-xs btn-danger" type="submit" name="RemoveButton"><i class="fa fa-trash"></i> {'Remove'|i18n('design/ocbootstrap/content/draft')}</button>
                        <input class="btn btn-xs btn-secondary" name="selectall" onclick=checkAll() type="button" value="{'Select all'|i18n('design/ocbootstrap/content/draft')}"/>
                    </td>
                    <td colspan="4" align="right" width="1">
                        <button class="btn btn-xs btn-danger" type="submit" name="EmptyButton"><i class="fa fa-trash"></i> {'Empty draft'|i18n('design/ocbootstrap/content/draft')}</button>
                    </td>
                </tr>
            </table>
            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri='/content/draft'
                     item_count=$list_count
                     view_parameters=$view_parameters
                     item_limit=$page_limit}
        {else}
            <p class="lead">{"You have no drafts"|i18n("design/ocbootstrap/content/draft")}</p>
        {/if}
    </form>
</div>
