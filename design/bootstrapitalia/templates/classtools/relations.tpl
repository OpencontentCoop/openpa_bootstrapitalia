<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="it" lang="it">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
    {literal}
    <style>
        html, body, p, img, h1, h2, h3, h4, h5, h6, #header, ul, li, ol, fieldset, abbr, acronym, form, input {
            border: none;
            margin: 0;
            padding: 0;
            font-family: sans-serif;
            font-size: 11px
        }

        html, body {
            height: 100%;
        }

        body {
            color: #000;
            text-align: left;
            background: #efefef;
            min-width: 800px;
        }

        table {
            border-collapse: collapse;
            border-spacing: 0;
            width: 200px;
            margin: 8px;
            box-shadow: 2px 4px 10px -6px #000;
        }

        .table-bordered {
            border: 2px solid #bbb;
        }

        .table > caption + thead > tr:first-child > td, .table > caption + thead > tr:first-child > th, .table > colgroup + thead > tr:first-child > td, .table > colgroup + thead > tr:first-child > th, .table > thead:first-child > tr:first-child > td, .table > thead:first-child > tr:first-child > th {
            border-top: 0;
        }

        .table-bordered > thead > tr > td, .table-bordered > thead > tr > th {
            border-bottom-width: 2px;
        }

        .table-bordered > tbody > tr > td, .table-bordered > tbody > tr > th, .table-bordered > tfoot > tr > td, .table-bordered > tfoot > tr > th, .table-bordered > thead > tr > td, .table-bordered > thead > tr > th {
            border-top: 2px solid #ddd;
            border-bottom: 2px solid #ddd;
        }

        .table > thead > tr > th {
            vertical-align: bottom;
            border-bottom: 2px solid #ddd;
        }

        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 5px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 2px solid #ddd;
        }

        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 5px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 2px solid #ddd;
        }

        td, th {
            background: #fff;
            opacity: .9;
            vertical-align: middle !important;
            line-height: 1 !important;
        }

        tr.{/literal}{$current.identifier}{literal} td, tr.related td {
            background: #ddd
        }

        table.collapsed tbody tr {
            display: none;
        }

        table.collapsed tr.{/literal}{$current.identifier}{literal}, table.collapsed tr.related {
            display: table-row;
        }

        th.class-title {
            background: rgba(83, 140, 191, 1);
            padding-bottom: 2px !important;
            border-bottom: none !important;
        }

        th.class-title a {
            color: #fff;
            text-decoration: none;
            font-size: 1.4em;
        }

        th.class-info {
            padding: 3px 5px !important;
            font-weight: normal;
            font-size: 0.875em;
            background: rgba(83, 140, 191, 1);
            color: #fff;
            border-bottom: none !important;
            border-top: none !important;
        }


        #inverse-wrapper {
            width: calc((100% - 250px)/2);
            float: left;
            z-index: 1;
            height: calc(100% - 50px);
            min-width: 250px;
        }

        #inverse, #current, #direct{
            z-index: 1;
        }

        #current-wrapper {
            left: calc((100% - 250px)/2);
            width: 250px;
            position: absolute;
            z-index: 1;
            height: calc(100% - 50px);
            top:50px;
        }

        #background {
            left: calc((100% - 250px)/2);
            width: 250px;
            position: absolute;
            z-index: 0;
            height: calc(100% - 50px);
            background: #fff;
            top:50px;
        }

        #direct-wrapper {
            width:calc((100% - 250px)/2);
            float: right;
            z-index: 1;
            min-height: 1px;
            height: calc(100% - 50px);
            min-width: 250px;
        }

        #compare{
            background: #fff;
            height: 50px;
        }
        span.hidden {
            text-decoration: line-through
        }

        canvas{
            z-index: 0;
        }
        table.current{
            margin: 10px auto;
        }


        /*== start of code for tooltips ==*/
        .tool {
            cursor: help;
            position: relative;
        }


        /*== common styles for both parts of tool tip ==*/
        .tool::before,
        .tool::after {
            left: 50%;
            opacity: 0;
            position: absolute;
            z-index: -100;
        }

        .tool:hover::before,
        .tool:focus::before,
        .tool:hover::after,
        .tool:focus::after {
            opacity: 1;
            transform: scale(1) translateY(0);
            z-index: 100;
        }


        /*== pointer tip ==*/
        .tool::before {
            border-style: solid;
            border-width: 1em 0.75em 0 0.75em;
            border-color: #3E474F transparent transparent transparent;
            bottom: 100%;
            content: "";
            margin-left: -0.5em;
            transition: all .65s cubic-bezier(.84,-0.18,.31,1.26), opacity .65s .5s;
            transform:  scale(.6) translateY(-90%);
        }

        .tool:hover::before,
        .tool:focus::before {
            transition: all .65s cubic-bezier(.84,-0.18,.31,1.26) .2s;
        }


        /*== speech bubble ==*/
        .tool::after {
            background: #3E474F;
            border-radius: .25em;
            bottom: 180%;
            color: #EDEFF0;
            content: attr(data-tip);
            margin-left: -60px;
            padding: 1em;
            transition: all .65s cubic-bezier(.84,-0.18,.31,1.26) .2s;
            transform: scale(.6) translateY(50%);
            width: 100px;
            text-align: center;
        }

        .tool:hover::after,
        .tool:focus::after  {
            transition: all .65s cubic-bezier(.84,-0.18,.31,1.26);
        }

        @media (max-width: 760px) {
            .tool::after {
                font-size: .75em;
                margin-left: -5em;
                width: 10em;
            }
        }event/ezxuserformtoken.php
    </style>
    {/literal}
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
    <script src={'javascript/jquery.masonry.min.js'|ezdesign()} type="text/javascript"></script>
    <script src={'javascript/jquery.jsPlumb-1.0.4-min.js'|ezdesign()} type="text/javascript"></script>
    <script type="text/javascript">
        var classBaseUrl = {'/classtools/compare'|ezurl()};
    {literal}
        (function ($) {
            $(document).ready(function () {
                function reshowPlumb() {
                    jsPlumb.detachEverything();
                    {/literal}
                    {foreach $inverse_relations as $class}{if $class.name}
                    $("table.class-{$class.identifier} .{$current.identifier}").plumb({ldelim}target: 'end-connect-{$current.identifier}'{rdelim});
                    {/if}{/foreach}
                    {foreach $direct_relations as $class}{if $class.name}
                    $("table.current .{$class.identifier}").plumb({ldelim}target: 'end-connect-{$class.identifier}'{rdelim});
                    {/if}{/foreach}
                    $("table.current .{$current.identifier}").plumb({ldelim}target: 'end-connect-{$current.identifier}'{rdelim});
                    {literal}
                    //$("li[id*='connect']").css('background-color', '#f5f5f5')
                    jsPlumb.repaintEverything();
                }

                $('#inverse').masonry({itemSelector: '.table'});
                $('#direct').masonry({itemSelector: '.table'});
                $(".table:not(.current)").draggable({
                    cursor: 'crosshair',
                    addClasses: false,
                    containment: 'body',
                    opacity: '0.3',
                    drag: function (a, b) {
                        reshowPlumb();
                    },
                    stop: function (a, b) {
                        reshowPlumb();
                    }
                });
                $('a.toggle').bind('click', function (e) {
                    var icon = $(this).find('i');
                    var table = $(this).parents('table');
                    if (table.hasClass('collapsed')) {
                        table.removeClass('collapsed');
                        icon.removeClass('fa-expand').addClass('fa-compress');
                    } else {
                        table.addClass('collapsed');
                        icon.addClass('fa-expand').removeClass('fa-compress');
                    }
                    $('#inverse').masonry({itemSelector: '.table'});
                    $('#direct').masonry({itemSelector: '.table'});
                    reshowPlumb()
                    e.preventDefault();
                });
                jsPlumb.setDraggableByDefault(false);
                jsPlumb.DEFAULT_PAINT_STYLE = {lineWidth: 2, strokeStyle: 'rgba(83,140,191,0.7)'};
                jsPlumb.DEFAULT_ENDPOINTS = [new jsPlumb.Endpoints.Dot({radius: 5}),
                    new jsPlumb.Endpoints.Dot({radius: 5})];
                jsPlumb.DEFAULT_CONNECTOR = new jsPlumb.Connectors.Bezier(60);
                jsPlumb.DEFAULT_ANCHORS = [jsPlumb.Anchors.RightMiddle, jsPlumb.Anchors.LeftMiddle];

                reshowPlumb();
                $(window).resize(function () {
                    $('#inverse').masonry({itemSelector: '.table'});
                    $('#direct').masonry({itemSelector: '.table'});
                    reshowPlumb();
                });

                var compare = function (remote, id, container) {
                    var url = classBaseUrl + '/' + id;
                    $.ajax({
                        type:     "get",
                        data:     {format: 'json', 'remote': remote},
                        cache:    false,
                        url:      url,
                        dataType: "json",
                        error: function (request, error) {
                            if(request.status===401)
                                container.html( '<div class="message-error text-center"><small>Unauthorized</small></div>' );
                            else
                                container.html( '<div class="message-error text-center"><strong>?</strong></div>' );
                        },
                        success: function (data) {
                            if (data.error){
                                container.html( '<div class="message-error text-center"><small>'+data.error+'</small></div>' );
                            }else {
                                $.each(data, function (index, value) {
                                    if (container.find('td.' + index).length > 0) {
                                        if (value) {
                                            container.find('td.' + index).html('<div class="message-error text-center"><strong>KO</strong></div>');
                                        } else {
                                            container.find('td.' + index).html('<div class="message-feedback text-center">OK</div>');
                                        }
                                        $("table.list").trigger("update");
                                    }
                                });
                            }
                        }
                    });
                };
            })
        })(jQuery);
        {/literal}</script>

</head>
<body>
<div id="compare">
    <h3 style="padding: 15px;font-size: 2em;text-align: center">{$current.name|wash()}</h3>
</div>
<div id="background"></div>
<div id="inverse-wrapper">
    <div id="inverse">
        {foreach $inverse_relations as $class}
            {include uri='design:classtools/parts/class_table.tpl' class=$class current=$current type=inverse}
        {/foreach}
    </div>
</div>

<div id="current-wrapper">
    <div id="current">
        {include uri='design:classtools/parts/class_table.tpl' class=$current current=$current}
    </div>
</div>

<div id="direct-wrapper">
    <div id="direct">
        {foreach $direct_relations as $class}
            {include uri='design:classtools/parts/class_table.tpl' class=$class current=$current type=direct}
        {/foreach}
    </div>
</div>


</body>
</html>