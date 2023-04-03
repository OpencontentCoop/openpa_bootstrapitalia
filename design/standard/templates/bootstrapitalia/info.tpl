{ezpagedata_set( 'has_container', true() )}
{def $pagedata = openpapagedata()}

<div class="container mb-3">
    <h2 class="mb-4">Gestioni contatti e informazioni generali</h2>

    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" enctype="multipart/form-data" class="form">
        {foreach $sections as $section}
            <div class="border border-light rounded p-3 mb-3">
                <h5>{$section.label}</h5>
                {foreach $section.contacts as $contact_identifier}
                    {def $contact = $contacts[$contact_identifier]}
                    <div class="row mb-3">
                        <label for="{$contact.identifier}" class="col-sm-3 col-form-label text-md-end">{$contact.label}</label>
                        <div class="col-sm-9">
                            <input type="text" name="Contacts[{$contact.label}]" class="form-control" id="{$contact.identifier}" value="{$contact.value}">
                        </div>
                    </div>
                    {undef $contact}
                {/foreach}
            </div>
        {/foreach}

        <div class="border border-light rounded p-3 mb-3">
            <h5>Logo</h5>
            <div class="row mb-3">
                <label for="Logo" class="col-sm-3 col-form-label">
                    {if $pagedata.header.logo.url}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="82"
                             height="82"
                             class="bg-primary"
                             src="{$pagedata.header.logo.url|ezroot(no)}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Logo" class="form-control" id="Logo" value="">
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12 text-right mt-3">
                <input type="submit" class="btn btn-success" name="Store" value="Salva"/>
            </div>
        </div>
    </form>