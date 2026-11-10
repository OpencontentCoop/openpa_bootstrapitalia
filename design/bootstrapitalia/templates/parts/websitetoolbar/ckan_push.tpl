{if and($content_object.class_identifier|eq('opendata_dataset'), ezmodule('ckan','push'))}
    <li>
        <a class="list-item left-icon"  href="{concat('ckan/push/', $content_object.id, '?format=html')|ezurl(no)}" title='Push to CKAN'>
            <i aria-hidden="true" class="fa fa-share-alt"></i>
            Dataset
        </a>
    </li>
{/if}