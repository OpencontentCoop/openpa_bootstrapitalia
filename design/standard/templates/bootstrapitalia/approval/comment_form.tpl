<div class="mx-5 p-5 mt-5 bg-light bg-opacity-50 border rounded">
    <form method="post" action="{concat('/bootstrapitalia/approval/version/', $approval_item.contentObjectVersionId, '/comment')|ezurl(no)}">
        <textarea required class="form-control border mb-2" rows="5" name="Comment"></textarea>
        <div class="text-end text-right">
            <input type="submit" value="Aggiungi commento" class="btn btn-secondary btn-md" name="AddCommentButton" />
        </div>
    </form>
</div>