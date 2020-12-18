<div class="block">
    <label for="ContentClass_openpamaskedstring_mask_{$class_attribute.id}">{'Mask'|i18n( 'design/standard/class/datatype' )}:</label>
    <p>Inserisci come segnaposto la stringa <code>%1$s</code></p>
    <input class="box"
           type="text"
           name="ContentClass_openpamaskedstring_mask_{$class_attribute.id}"
           id="ContentClass_openpamaskedstring_mask_{$class_attribute.id}"
           value="{$class_attribute.data_text5|wash}"
    />
</div>
