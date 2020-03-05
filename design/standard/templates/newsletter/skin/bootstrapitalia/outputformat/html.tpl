{def $site_url = concat('https://', ezini('SiteSettings', 'SiteURL', 'site.ini'))}
{def $main_node = $contentobject.contentobject.main_node}
{def $children_count = $main_node.children_count}
{def $children = fetch('content', 'list', hash( 'parent_node_id', $main_node.node_id,
                                                'sort_by', array( 'priority', true() ) ) )}

{set-block variable=$subject scope=root}{ezini('NewsletterMailSettings', 'EmailSubjectPrefix', 'cjw_newsletter.ini')} {$contentobject.name|wash}{/set-block}

{def $base_bg_color = header_color()}
{def $footer_bg_color = footer_color()}

<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
  <head>
    <title></title>
    <!--[if !mso]><!-- -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <!--<![endif]-->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/style.tpl'}
    
  </head>
  <body style="background-color:#eee;">
    <div style="background-color:#eee;">
      
      {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/header.tpl'}

      {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/intro.tpl'}

      {if $children_count|gt(0)}
        {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/one_column_content.tpl' content=$children[0]}

        {if $children_count|eq(2)}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/one_column_content.tpl' content=$children[1]}
        {/if}

        {if $children_count|eq(3)}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/two_column_contents.tpl' contents=array($children[1], $children[2])}
        {/if}

        {if $children_count|eq(4)}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/one_column_content.tpl' content=$children[1]}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/two_column_contents.tpl' contents=array($children[2], $children[3])}
        {/if}

        {if $children_count|ge(5)}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/two_column_contents.tpl' contents=array($children[1], $children[2])}
          {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/two_column_contents.tpl' contents=array($children[3], $children[4])}
        {/if}

        {if $children_count|gt(5)}
          {foreach $children as $index => $content}
            {if $index|gt(4)}
              {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/list_content.tpl' content=$content}
            {/if}
          {/foreach}
        {/if}
      {/if}

      {include uri='design:newsletter/skin/bootstrapitalia/outputformat/include/footer.tpl'}

    </div>
  </body>
</html>
