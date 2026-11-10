{if $content_object.class_identifier|eq('organigramma')}
    <li>
        <a class="list-item left-icon"
           href="{concat('openpa/refreshorganigramma/',$node.contentobject_id)|ezurl(no)}">
            <i aria-hidden="true" class="fa fa-code-fork"></i>
            Aggiorna organigramma
        </a>
    </li>
    <li><span class="divider"></span></li>
{/if}