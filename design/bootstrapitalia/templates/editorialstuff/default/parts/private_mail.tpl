<div class="panel-body" style="background: #fff">
    <form class="form" action="{concat('editorialstuff/action/', $factory_identifier, '/', $post.object_id, '#tab_private_mail')|ezurl(no)}"
          enctype="multipart/form-data" method="post">

        <div class="form-group">
            <label class="d-none" for=subject_private_message">Oggetto del messaggio</label>
            <input required type="text" id=subject_private_message" class="form-control" name="ActionParameters[subject]" placeholder="Oggetto del messaggio" />
        </div>

        <div class="form-group mb-4">
            <label class="d-none" for=text_private_message">Testo del messaggio</label>
            <textarea required rows="6" id=text_private_message" class="form-control border" name="ActionParameters[text]" placeholder="Testo del messaggio"></textarea>
        </div>

        <div class="form-group text-right">
            <button type="submit" name="ActionSendPrivateMessage" class="btn btn-success">{'Send'|i18n('bootstrapitalia')}</button>
            <input type="hidden" name="ActionIdentifier" value="ActionSendPrivateMessage"/>
        </div>

    </form>
</div>
