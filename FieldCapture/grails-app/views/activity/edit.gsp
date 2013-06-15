<%@ page import="org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Edit | ${activity.activityId ?: 'new'} | ${site.name} | ${site.projectName} | Field Capture</title>
    <style type="text/css">
    legend {
        border: none;
        margin-bottom: 5px;
    }
    .popover {
        border-width: 2px;
    }
    .popover-content {
        font-size: 14px;
        line-height: 20px;
    }
    h1 input[type="text"] {
        color: #333a3f;
        font-size: 28px;
        /*line-height: 40px;*/
        font-weight: bold;
        font-family: Arial, Helvetica, sans-serif;
        height: 42px;
    }
    .no-border { border-top: none !important; }
    </style>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <legend>
        <table style="width: 100%">
            <tr>
                <td><g:link class="discreet" controller="home" action="index">Activities</g:link><fc:navSeparator/>create</td>
                <td style="text-align: right"><span><button id="btnDeleteAll" class="btn btn-danger btn-small"><i class="icon-remove icon-white"></i>&nbsp;Delete activity</button></span></td>
            </tr>
        </table>
    </legend>

    <div class="row-fluid">
        <div class="span6 title-attribute">
            <h2 class="inline">Project: </h2><g:link controller="project" action="index" id="${project.projectId}">${project.name}</g:link>
        </div>
        <div class="span6 title-attribute">
            <h2>Site: </h2><g:link controller="site" action="index" id="${site.siteId}">${site.name}</g:link>
        </div>
    </div>

    <bs:form action="update" inline="true">
        <div class="row-fluid">
            <div class="span6">
                <fc:textArea data-bind="value: description" id="description" label="Description" class="span12" rows="3" cols="50"/>
            </div>
            <div class="span6">
                <fc:textArea data-bind="value: notes" id="notes" label="Notes" class="span12" rows="3" cols="50"/>
            </div>
        </div>

        <div class="row-fluid control-group">
            <label for="type">Type of activity</label>
            <select data-bind="value: type" id="type" data-validation-engine="validate[required]">
                <g:each in="${activityTypes}" var="t" status="i">
                    <g:if test="${i == 0 && create}">
                        <option></option>
                    </g:if>
                    <optgroup label="${t.name}">
                        <g:each in="${t.list}" var="opt">
                            <option>${opt.name}</option>
                        </g:each>
                    </optgroup>
                </g:each>
            </select>
            %{--<select data-bind="value: type, options: availableTypes, optionsText: 'name'" id="type"></select>--}%
        </div>

        <div class="row-fluid">
            <div class="span4 control-group">
                <label for="startDate">Start date
                <fc:iconHelp title="Start date">Date the activity was started.</fc:iconHelp>
                </label>
                <div class="input-append">
                    <input data-bind="datepicker:startDate.date" id="startDate" type="text" size="16"
                       data-validation-engine="validate[required]"/>
                    <span class="add-on open-datepicker"><i class="icon-th"></i></span>
                </div>
            </div>
            <div class="span4">
                <label for="endDate">End date
                <fc:iconHelp title="End date">Date the activity finished.</fc:iconHelp>
                </label>
                <div class="input-append">
                    <input data-bind="datepicker:endDate.date" id="endDate" type="text" size="16"
                       data-validation-engine="validate[required]"/>
                    <span class="add-on open-datepicker"><i class="icon-th"></i></span>
                </div>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4">
                <label for="censusMethod">Census method</label>
                <input data-bind="value: censusMethod" id="censusMethod" type="text" class="span12"/>
            </div>
            <div class="span4">
                <label for="methodAccuracy">Method accuracy</label>
                <input data-bind="value: methodAccuracy" id="methodAccuracy" type="text" class="span12"/>
            </div>
            <div class="span4">
                <label for="collector">Collector</label>
                <input data-bind="value: collector" id="collector" type="text" class="span12"/>
            </div>
        </div>

        <div class="row-fluid">
            <fc:textArea data-bind="value: fieldNotes" id="fieldNotes" label="Field notes" class="span12" rows="3" cols="50"/>
        </div>

        <div class="form-actions">
            <button type="button" data-bind="click: save" class="btn btn-primary">Save changes</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
        </div>
    </bs:form>

    <hr />
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
            <h4>Activity</h4>
            <pre>${activity}</pre>
            <h4>Site</h4>
            <pre>${site}</pre>
            <h4>Project</h4>
            <pre>${project}</pre>
            %{--<pre>Map features : ${mapFeatures}</pre>--}%
        </div>
    </div>
</div>

<!-- templates -->

<r:script>

    var returnTo = "${grailsApplication.config.grails.serverURL + '/' + returnTo}";
    $(function(){

        $('#validation-container').validationEngine('attach', {scroll: false});

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#cancel').click(function () {
            document.location.href = returnTo;
        });

        //ko.validation.init();

        function ViewModel () {
            var self = this;
            self.description = ko.observable("${activity.description}");
            self.notes = ko.observable("${activity.notes}");
            self.startDate = ko.observable("${activity.startDate}").extend({simpleDate: false});
            self.endDate = ko.observable("${activity.endDate}").extend({simpleDate: false});
            self.censusMethod = ko.observable("${activity.censusMethod}");
            self.methodAccuracy = ko.observable("${activity.methodAccuracy}");
            self.collector = ko.observable("${activity.collector}")/*.extend({ required: true })*/;
            self.fieldNotes = ko.observable("${activity.fieldNotes}");
            self.type = ko.observable("${activity.type}");
            self.siteId = ko.observable("${activity.siteId}");
            self.projectId = ko.observable("${activity.projectId}");

            self.save = function () {
                if ($('#validation-container').validationEngine('validate')) {
                    var jsData = ko.toJS(self);
                    var json = JSON.stringify(jsData);
                    $.ajax({
                        url: "${createLink(action: 'ajaxUpdate', id: activity.activityId)}",
                        type: 'POST',
                        data: json,
                        contentType: 'application/json',
                        success: function (data) {
                            if (data.error) {
                                alert(data.detail + ' \n' + data.error);
                            } else {
                                document.location.href = returnTo;
                            }
                        },
                        error: function (data) {
                            var status = data.status
                            alert('An unhandled error occurred: ' + data.status);
                        }
                    });
                }
            };
            self.notImplemented = function () {
                alert("Not implemented yet.")
            };
        }

        var viewModel = new ViewModel();
        ko.applyBindings(viewModel);

    });

</r:script>
</body>
</html>