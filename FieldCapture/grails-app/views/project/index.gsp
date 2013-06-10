<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta name="layout" content="main"/>
  <title>${project?.project_name} | Field Capture</title>
    <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&language=en"></script>
    <r:script disposition="head">
    var fcConfig = {
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        activityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
    }
    </r:script>
    <r:require modules="gmap3,mapWithFeatures,knockout,amplify"/>
</head>
<body>
<div class="container-fluid">

    <legend>
        <table style="width: 100%">
            <tr>
                <td>Project<fc:navSeparator/>${project.name}</td>
            </tr>
        </table>
    </legend>

    <div class="row-fluid">
        <div class="row-fluid">
            <div class="clearfix">
                <h1 class="pull-left">${project?.name}</h1>
                <g:link action="edit" id="${project.projectId}" class="btn pull-right title-btn">Edit project</g:link>
            </div>
            <div>
                <a href="${grailsApplication.config.collectory.baseURL +
                        'public/show/' + project.organisation}">${organisationName}</a>
            </div>
            <div>
                <p class="well well-small more">${project.description}</p>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="pull-left">
            <h2>Activities</h2>
        </div>
        <div class="pull-right" style="margin-top: 30px;">
            <button data-bind="click: $root.notImplemented" type="button" class="btn">Add new activity</button>
        </div>
    </div>
    <div class="row-fluid">
        <table class="table table-condensed" id="activities">
            <thead>
                <tr><th></th><th>Type</th><th>From</th><th>To</th><th>Site</th></tr>
            </thead>
            <tbody data-bind="foreach:activities" id="activityList">
                <tr data-bind="attr:{href:'#'+activityId}" data-toggle="collapse" class="accordion-toggle">
                    <td>
                        <div>
                            <a><i class="icon-plus" title="expand"></i></a>
                        </div>
                    </td>
                    <td><span data-bind="text:type"></span></td>
                    <td><span data-bind="text:startDate.formattedDate"></span></td>
                    <td><span data-bind="text:endDate.formattedDate"></span></td>
                    <td><a data-bind="siteName:siteId, click: $root.openSite"></a></td>
                </tr>
                <tr class="hidden-row">
                    <td></td>
                    <td colspan="5">
                        <div class="collapse" data-bind="attr: {id:activityId}">
                            <ul class="unstyled well well-small"
                                data-bind="foreachModelOutput:metaModel.outputs">
                                <li>
                                    <div class="row-fluid">
                                        <span class="span4" data-bind="text:name"></span>
                                        <span class="span3" data-bind="text:score"></span>
                                        <span class="span1 offset1">
                                            <a data-bind="attr: {href: '${createLink(controller: "output", action: "edit")}' + '/' + outputId}">
                                                <i data-bind="attr: {title: outputId == '' ? 'Add data' : 'Edit data'}" class="icon-edit"></i>
                                            </a>
                                        </span>
                                    </div>
                                </li>

                            </ul>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="row-fluid">
        <div class="pull-left">
            <h2>Sites</h2>
            <div class="span12">There are <span data-bind="text: sites().length"></span> sites.</div>
        </div>
        <div class="pull-right" style="margin-top: 30px;">
            <button data-bind="click: $root.addSite" type="button" class="btn">Add new site</button>
            <button data-bind="click: $root.removeAllSites" type="button" class="btn">Delete all sites</button>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span5" id="sites-scroller">
            <ul class="unstyled inline" data-bind="foreach: sites">
                <li class="siteInstance" data-bind="event: {mouseover: $root.highlight, mouseout: $root.unhighlight}">
                    <a data-bind="text: name, click: $root.openSite"></a>
                    <button data-bind="click: $root.removeSite" type="button" class="close" title="delete">&times;</button>
                </li>
            </ul>
        </div>
        <div class="span7">
            <div id="map"></div>
        </div>
    </div>

    <hr />
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
            <h4>Activities</h4>
            <pre data-bind="text:ko.toJSON(activities,null,2)"></pre>
            <h4>Sites</h4>
            <pre>${json}</pre>
            <h4>Project</h4>
            <pre>${project}</pre>
            %{--<pre>Map features : ${mapFeatures}</pre>--}%
        </div>
    </div>
</div>
    <r:script>
        $(window).load(function () {
            var json = $.parseJSON('${json}');
            var map = init_map_with_features({
                    mapContainer: "map",
                    scrollwheel: false
                },
                $.parseJSON('${mapFeatures}')
            );
            // setup 'read more' for long text
            $('.more').shorten({
                moreText: 'read more',
                showChars: '270'
            });
            // setup confirm modals for deletions
            $(document).on("click", "a[data-bb]", function(e) {
                e.preventDefault();
                var type = $(this).data("bb"),
                    href = $(this).attr('href');
                if (type === 'confirm') {
                    bootbox.confirm("Delete this entire project? Are you sure?", function(result) {
                        if (result) {
                            document.location.href = href;
                        }
                    });
                }
            });
            // change toggle icon when expanding and collapsing and track open state
            $('#activities').
            on('show', 'div.collapse', function() {
                $(this).parents('tr').prev().find('td:first-child i').
                    removeClass('icon-plus').addClass('icon-minus');
            }).
            on('hide', 'div.collapse', function() {
                $(this).parents('tr').prev().find('td:first-child i').
                    removeClass('icon-minus').addClass('icon-plus');
            }).
            on('shown', 'div.collapse', function() {
                trackState();
            }).
            on('hidden', 'div.collapse', function() {
                trackState();
            });

            function trackState () {
                var $leaves = $('#activityList div.collapse'),
                    state = [];
                $.each($leaves, function (i, leaf) {
                    state.push($(leaf).hasClass('in'));
                });
                amplify.store.sessionStorage('output-accordion-state',state);
            }

            function readState () {
                var hidden = $('#activityList div.collapse'),
                    state = amplify.store.sessionStorage('output-accordion-state');
                $.each(hidden, function (i, leaf) {
                    if (state !== undefined && i < state.length && state[i]) {
                        $(leaf).collapse('show');
                    }
                });
            }

            //iterates over the outputs specified in the meta-model and builds a temp object for
            // each containing the name, and the score and id of any matching outputs in the data
            ko.bindingHandlers.foreachModelOutput = {
                init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                    var metaOutputs = ko.utils.unwrapObservable(valueAccessor()),
                        activity = bindingContext.$data,
                        transformedOutputs = [];

                    $.each(metaOutputs, function (i, name) {
                        var score = "Not assessed yet.",
                            outputId = '';

                        // search for corresponding outputs in the data
                        $.each(activity.outputs(), function (i,output) {
                            if (output.name === name) {
                                outputId = output.outputId;
                                // the data structure allows for multiple scores per output
                                // not clear yet if this is required but for now just assume one
                                for (var key in output.scores) {
                                    if (output.scores.hasOwnProperty(key)) {
                                        score = output.scores[key];
                                    }
                                }
                            }
                        });

                        // build the array that we will actually iterate over in the inner template
                        transformedOutputs.push({name: name, score: score, outputId: outputId});
                    });

                    // re-cast the binding to iterate over our new array
                    ko.applyBindingsToNode(element, { foreach: transformedOutputs });
                    return { controlsDescendantBindings: true };
                }
            };

            // todo: not used here but is handy so should go into the common custom ko bindings
            ko.bindingHandlers.foreachprop = {
                transformObject: function (obj) {
                    var properties = [];
                    for (var key in obj) {
                        if (obj.hasOwnProperty(key)) {
                            properties.push({ key: key, value: obj[key] });
                        }
                    }
                    return properties;
                },
                init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                    var value = ko.utils.unwrapObservable(valueAccessor()),
                        properties = ko.bindingHandlers.foreachprop.transformObject(value);
                    ko.applyBindingsToNode(element, { foreach: properties });
                    return { controlsDescendantBindings: true };
                }
            };

            // not used but left for reference
            ko.bindingHandlers.siteName =  {
                init: function(element, valueAccessor, allBindingsAccessor, model, bindingContext) {
                    var siteId = ko.utils.unwrapObservable(valueAccessor()),
                        site,
                        sites = bindingContext.$root.sites();
                    if (siteId) {
                        site = $.grep(sites, function(obj, i) {
                            return (obj.siteId() === siteId);
                        });
                        if (site.length > 0) {
                            $(element).html(site[0].name());
                            return;
                        }
                    }
                    $(element).html('no site');
                }
            };

            function ViewModel(project, sites, activities, assessments) {
                var self = this;
                this.loadActivities = function (activities) {
                    var acts = ko.observableArray([]);
                    $.each(activities, function (i, act) {
                        var activity = {
                            activityId: act.activityId,
                            siteId: act.siteId,
                            type: act.type,
                            startDate: ko.observable(act.startDate).extend({simpleDate:false}),
                            endDate: ko.observable(act.endDate).extend({simpleDate:false}),
                            outputs: ko.observableArray([]),
                            collector: act.collector,
                            metaModel: act.model
                        };
                        $.each(act.outputs, function (j, out) {
                            activity.outputs.push({
                                outputId: out.outputId,
                                name: out.name,
                                collector: out.collector,
                                assessmentDate: out.assessmentDate,
                                scores: out.scores
                            });
                        });
                        acts.push(activity);
                    });
                    return acts;
                };
                self.name = ko.observable(project.name);
                self.description = ko.observable(project.description);
                self.externalId = ko.observable(project.externalId);
                self.grantId = ko.observable(project.grantId);
                self.manager = ko.observable(project.manager);
                self.plannedStartDate = ko.observable(project.plannedStartDate).extend({simpleDate: false});
                self.plannedEndDate = ko.observable(project.plannedEndDate).extend({simpleDate: false});
                self.organisation = ko.observable(project.organisation);
                self.activities = self.loadActivities(activities);
                this.sites = ko.mapping.fromJS(sites);
                this.removeSite = function () {
                   var that = this,
                       url = fcConfig.siteDeleteUrl + '/' + this.siteId();
                    $.get(url, function (data) {
                        if (data.status === 'deleted') {
                            self.sites.remove(that);
                        }
                    });
                };
                this.openSite = function () {
                    var site = ko.toJS(this);
                    document.location.href = fcConfig.siteViewUrl + '/' + site.siteId;
                };
                this.openActivity = function () {
                    document.location.href = fcConfig.activityViewUrl + '/' + this.activityId();
                };
                this.highlight = function () {
                    map.highlightFeatureById(this.name());
                };
                this.unhighlight = function () {
                    map.unHighlightFeatureById(this.name());
                };
                this.removeAllSites = function () {
                    self.notImplemented();
                };
                this.addSite = function () {
                    self.notImplemented();
                };
                self.notImplemented = function () {
                    alert("Not implemented yet.")
                };
            }

            var viewModel = new ViewModel(${project},json,${activities ?: []},${assessments ?: []});

            ko. applyBindings(viewModel);

            readState();
        });

    </r:script>
</body>
</html>