{ezscript_require( 'ezjsc::jquery' )}
<div class="survey-view">
	{def $survey=$attribute.content.survey}
	{if is_set($attribute.content.survey_validation.one_answer_need_login)}
		<div class="alert alert-danger"><p>{"You need to log in in order to answer this survey"|i18n('survey')}.</p></div>
	{else}
		{if $survey.valid|eq(false())}
			<div class="alert alert-danger"><p>{"The survey is not active"|i18n('survey')}.</p></div>
    	{else}
			{def $survey_validation=$attribute.content.survey_validation}
			{if or(is_set( $survey_validation.one_answer ), and(is_set($survey_validation.one_answer_count), $survey_validation.one_answer_count|gt(0)))}
				<div class="alert alert-danger"><p>{"The survey does already have an answer from you"|i18n('survey')}.</p></div>
			{else}
				{def $prefixAttribute = 'ContentObjectAttribute'}
				{def $node = fetch( 'content', 'node', hash( 'node_id', module_params().parameters.NodeID ))}
				{def $module_param_value = concat(module_params().module_name,'/', module_params().function_name)}
				{if $module_param_value|ne('content/edit')}
					<form enctype="multipart/form-data" method="post" action={$node.url_alias|ezurl()} onsubmit="return checkSubmit();">
				{/if}

				<input type="hidden" name="{$prefixAttribute}_ezsurvey_contentobjectattribute_id_{$attribute.id}" value="{$attribute.id}" />
				<input type="hidden" name="{$prefixAttribute}_ezsurvey_node_id_{$attribute.id}" value="{module_params().parameters.NodeID}" />
				<input type="hidden" name="{$prefixAttribute}_ezsurvey_id_{$attribute.id}" value="{$survey.id}" />
				<input type="hidden" name="{$prefixAttribute}_ezsurvey_id_view_mode_{$attribute.id}" value="{$survey.id}" />

				<div class="alert alert-info">{"Questions marked with %mark% are required."|i18n('survey', '', hash( '%mark%', '<strong class="required">*</strong>' ) )}</div>

				{if or( is_unset( $preview ), not( $preview ))}
					{include uri="design:survey/view_validation.tpl"}
				{/if}

				{* check if we have a page break in the survey to know how to display it *}
				{def $pagebreak = 0}
				{foreach $survey.questions as $question}{if $question.visible}{if eq( $question.type, 'Pagebreak' )}{set $pagebreak = 1}{/if}{/if}{/foreach}

				{* check if there are validation errors and if so disable pagination and only show questions that need an answer *}
				{def $pagination = 1}
				{def $errorList = array()}
				{if is_set( $survey_validation.errors )}{set $pagination = 0}{foreach $survey_validation.errors as $error}{set $errorList = $errorList|append( $error.question_number )}{/foreach}{/if}
				{def $currentPage = 1}

				{if $pagination}
					<div id="survey-page{$currentPage}">
				{/if}
				{foreach $survey.questions as $question}
					{if $question.visible}
						{if and( eq( $question.type, 'Pagebreak' ), $pagination )}
							{set $currentPage = $currentPage|inc}
							</div>
							<div id="survey-page{$currentPage}">
						{elseif ne( $question.type, 'Pagebreak' )}
							{if and( $pagebreak, not( $pagination ), not( $errorList|contains( $question.question_number )), ne( $question.type, 'Receiver' ))}
								{* these questions are either filled properly or not mandatory => put them in a block that we'll hide *}
								<div class="question-container">
								<div id="toggle-{$question.question_number}" class="toggle-button" style="display: none;" onclick="toggleQuestion({$question.question_number})">Hide question {$question.question_number}</div>
								<div id="question-container-{$question.question_number}">
							{/if}
							<div class="clearfix">
								<input type="hidden" name="{$prefixAttribute}_ezsurvey_question_list_{$attribute.id}[]" value="{$question.id}" />
								<a name="survey_question_{$question.question_number}"></a>
								{survey_question_view_gui question=$question question_result=0 attribute_id=$attribute.id prefix_attribute=$prefixAttribute}
							</div>
							{if and( $pagebreak, not( $pagination ), not( $errorList|contains( $question.question_number )), ne( $question.type, 'Receiver' ))}
								</div>
								</div>
							{/if}
						{/if}
					{/if}
				{/foreach}

			   <input class="btn btn-primary btn-lg pull-right" type="submit" name="{$prefixAttribute}_ezsurvey_store_button_{$attribute.id}" value="{'Submit'|i18n( 'survey' )}" />

				{if $pagination}
					</div>
				{/if}

				{if and( $pagination, gt( $currentPage, 1 ))}
					<div id="survey-pagination" class="clearfix" style="display: none;">
						<div class="pull-right">
							<a href="javascript://" onclick="switchPage(2)" class="btn btn-success btn-lg">Avanti</a>
							<p class="hide">1/{$currentPage}</p>
						</div>
					</div>
				{/if}

				{if $module_param_value|ne('content/edit')}
				</form>
				{/if}
			{/if}
		{/if}
	{/if}
</div>

{if is_set($currentPage)}
<script type="text/javascript">
	var surveyPages = {$currentPage};
	var currentPage = 1;
	{literal}
	$(document).ready(function() {
		if( surveyPages > 1 ) {
			for( i=2; i<=surveyPages; i++ ) {
				$('#survey-page'+i).hide();
			}
			$('#survey-pagination').show();
		}
		$('.toggle-button').show();
		$('.toggle-button').each(function(){
			var number = $(this).attr('id').substr(7);
			toggleQuestion(number);
		});
	});
	function switchPage( page ) {
		$('#survey-page'+currentPage).hide();
		currentPage = page;
		$('#survey-page'+currentPage).show();
		var pagination = '';
		if( currentPage > 1 ) {
			pagination += '<div class="pull-left"><a href="javascript://" onclick="switchPage(' + (page-1) + ')" class="btn btn-success btn-lg">Indietro</a><p class="hide">' + page + '/' + surveyPages + '</p></div>';
		}
		if( currentPage < surveyPages ) {
			pagination += '<div class="pull-right"><a href="javascript://" onclick="switchPage(' + (page+1) + ')" class="btn btn-success btn-lg">Avanti</a><p class="hide">' + page + '/' + surveyPages + '</p></div>';
		}
		$('#survey-pagination').html( pagination );
	}
	function checkSubmit() {
		//make sure we can't submit a survey from other than the last page
		if( currentPage != surveyPages ) {
			return false;
		}
		return true;
	}
	function toggleQuestion( question ) {
		$('#question-container-'+question).toggle();
		if( $('#question-container-'+question).is(":visible") ) {
			$('#toggle-'+question).html( 'Nascondi domanda ' + question );
		}else{
			$('#toggle-'+question).html( 'Mostra domanda ' + question );
		}
	}
	{/literal}
</script>
{/if}