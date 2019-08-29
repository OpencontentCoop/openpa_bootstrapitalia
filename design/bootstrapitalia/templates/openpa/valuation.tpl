{*
	TEMPLATE  per la valutazione delle pagine da parte degli utenti
	node_id	nodo di riferimento
*}

{def $valuations=fetch( 'content', 'class', hash( 'class_id', 'valuation' ) )}

{if and( $valuations|count(), $valuations.object_list|count() )}
<div class="valuation clearfix p-3 analogue-1-bg-a1">

{def $valutazione=$valuations.object_list[0]
	 $node = fetch(content,node,hash(node_id,$node_id))
	 $data_map=$valutazione.data_map}

    <h5 class="text-center m-0 p-2">
        <a data-toggle="collapse" href="#valuationForm" role="button" aria-expanded="false" aria-controls="valuationForm" class="text-secondary">{$valutazione.name|wash()}</a>
    </h5>

    <form action="{'/content/action'|ezurl(no)}" method="post" id="valuationForm" class="collapse">
        <div class="row">
            <div class="col-md-4">
                {if is_set( $data_map.useful )}
                <div class="form-group">
                    <input type="hidden" value="" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.useful.id}" />
                    <strong>{$data_map.useful.contentclass_attribute_name|wash()}</strong>
                        <div class="form-check">
                            <input id="utilita1" class="form-check-input" type="radio" value="0" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.useful.id}[]" />
                            <label class="form-check-label" for="utilita1">per nulla</label>
                        </div>
                        <div class="form-check">
                            <input id="utilita2" class="form-check-input" type="radio" value="1" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.useful.id}[]" />
                            <label class="form-check-label" for="utilita2">poco</label>
                        </div>
                        <div class="form-check">
                            <input id="utilita3" class="form-check-input" type="radio" value="2" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.useful.id}[]" />
                            <label class="form-check-label" for="utilita3">abbastanza</label>
                        </div>
                        <div class="form-check">
                            <input id="utilita4" class="form-check-input" type="radio" value="3" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.useful.id}[]" />
                            <label class="form-check-label" for="utilita4">molto</label>
                        </div>
                </div>
                {/if}
            </div>
            <div class="col-md-4">
                {if is_set( $data_map.easy )}
                <div class="form-group">
                    <input type="hidden" value="" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.easy.id}" />
                    <strong>{$data_map.easy.contentclass_attribute_name|wash()}</strong>
                        <div class="form-check">
                            <input id="semplicita1" class="form-check-input" type="radio" value="0" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.easy.id}[]" />
                            <label class="form-check-label" for="semplicita1">per nulla</label>
                        </div>
                        <div class="form-check">
                            <input id="semplicita2" class="form-check-input" type="radio" value="1" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.easy.id}[]" />
                            <label class="form-check-label" for="semplicita2">poco</label>
                        </div>
                        <div class="form-check">
                            <input id="semplicita3" class="form-check-input" type="radio" value="2" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.easy.id}[]" />
                            <label class="form-check-label" for="semplicita3">abbastanza</label>
                        </div>
                        <div class="form-check">
                            <input id="semplicita4" class="form-check-input" type="radio" value="3" name="ContentObjectAttribute_ezselect_selected_array_{$data_map.easy.id}[]" />
                            <label class="form-check-label" for="semplicita4">molto</label>
                        </div>
                </div>
                {/if}
            </div>
            <div class="col-md-4">
                {if is_set( $data_map.email_aiutaci )}
                    <div class="form-group">
                        <label for="helpemail_aiutaci" class="control-label w-auto">{$data_map.email_aiutaci.contentclass_attribute_name|wash()}</label>
                        <input id="helpemail_aiutaci" class="form-control" type="text" value="" name="ContentObjectAttribute_ezstring_data_text_{$data_map.email_aiutaci.id}"  />
                    </div>
                {/if}
                {if is_set( $data_map.comment )}
                    <div class="form-group">
                        <label for="helpcomment" class="control-label w-auto">{$data_map.comment.contentclass_attribute_name|wash()}</label>
                        <textarea style="height: 100px" id="helpcomment" name="ContentObjectAttribute_ezstring_data_text_{$data_map.comment.id}" cols="20" rows="4"></textarea>
                    </div>
                {/if}
            </div>
        </div>

        <div class="row">
            <div class="col-md-8">
                {if is_set($data_map.antispam)}
                    {if $data_map.antispam.data_type_string|eq('ocrecaptcha')}
                        <div class="form-group">
                            <strong>{$data_map.antispam.contentclass_attribute_name|wash()}</strong>
                            {attribute_view_gui attribute=$data_map.antispam}
                        </div>
                    {else}
                        <link rel="stylesheet" href="{'stylesheets/nxc.captcha.css'|ezdesign(no)}" property='stylesheet' />

                        {ezscript_require( array( 'nxc.captcha.js' ) )}

                        {def $attribute = $data_map.antispam
                             $class_content = $attribute.contentclass_attribute.content
                             $regenerate = 1}
                        {if ezhttp( 'ActionCollectInformation', 'post', true() )}
                            {set $regenerate = 0}
                        {/if}

                        {if eq( $attribute.data_int, 1 )}
                            <strong>Antispam</strong>
                            <div class="captcha d-flex">
                                         <div>
                                        <img id="nxc-captcha-{$attribute.id}" alt="{'Secure code'|i18n( 'extension/nxc_captcha' )}" title="{'Secure code'|i18n( 'extension/nxc_captcha' )}" src="{concat( 'nxc_captcha/get/', $attribute.contentclass_attribute.id, '/nxc_captcha_collection_attribute_', $attribute.id, '/', $regenerate )|ezurl( 'no' )}" />
                                         <a href="{concat( 'nxc_captcha/get/', $attribute.contentclass_attribute.id, '/nxc_captcha_collection_attribute_', $attribute.id, '/1' )|ezurl( 'no' )}" class="nxc-captcha-regenerate float-right m-2" id="nxc-captcha-regenerate-{$attribute.id}" style="display: block;"><span class="sr-only">Ricarica</span> <i class="fa fa-refresh"></i> </a>
                                         </div>
                                         <div>
                                             <input class="captcha-input form-control form-control-sm" id="nxc-captcha-collection-input-{$attribute.id}" type="text" name="nxc_captcha_{$attribute.id}" value="" size="{$class_content.length.value}" maxlength="{$class_content.length.value}" />
                                         <small class="form-text text-muted">Inserisci il codice di sicurezza che vedi nell'immagine per proteggere il sito dallo spam </small>
                                    </div>
                            </div>

                        {else}
                            {*<p>{'Secure code is allready entered'|i18n( 'extension/nxc_captcha' )}</p>*}
                            <input type="hidden" name="nxc_captcha_{$attribute.id}" value="" />
                        {/if}
                        {undef $attribute $class_content $regenerate}
                    {/if}
                {/if}
            </div>
            <div class="col-md-4 mt-5">
                <input type="hidden" value="Nodo: {$node.node_id}; Oggetto:{$node.contentobject_id}; Versione: {$node.contentobject_version}; Titolo: {$node.name|wash()}" name="ContentObjectAttribute_ezstring_data_text_{$data_map.nodo.id}" />
                <input class="box" type="hidden" value="{$node.url_alias|ezurl(no,full)}" name="ContentObjectAttribute_ezstring_data_text_{$data_map.link.id}" />
                <input type="hidden" value="{$valutazione.main_node.node_id}" name="TopLevelNode"/>
                <input type="hidden" value="{$valutazione.main_node.node_id}" name="ContentNodeID"/>
                <input type="hidden" value="{$valutazione.id}" name="ContentObjectID"/>
                <input type="hidden" name="ViewMode" value="full" />
                <input class="btn btn-success btn-lg float-right" type="submit" value="Invia la valutazione" name="ActionCollectInformation"/>
                    </div>
        </div>
    </form>

</div>
{/if}
