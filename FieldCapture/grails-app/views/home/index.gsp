<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
  <meta name="layout" content="main"/>
  <title>Field Capture</title>
  <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&language=en"></script>
  <r:script disposition="head">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
    }
  </r:script>
  <r:require modules="knockout,mapWithFeatures"/>
</head>
<body>
    <div id="wrapper" class="container-fluid">
    <div class="row-fluid large-space-after">
        <div class="span12" id="header">
            <h1 class="pull-left">Field Capture</h1>
            <form action="search" class="form-horizontal pull-right" style="padding-top:5px;">
                <div class="input-append">
                    <g:textField class="input-large" name="search"/>
                    <button class="btn" type="submit">Search</button>
                </div>
            </form>
        </div>

        <g:if test="${flash.error}">
            <div class="row-fluid">
                <div class="alert alert-error">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    <span>${flash.error}</span>
                </div>
            </div>
        </g:if>
    </div>

    <div class="hide row-fluid large-space-after large-space-before button-set">
        <g:link controller="project" action="create" class="btn btn-large"><r:img dir="images/icons" file="project.png"/> Add a project</g:link>
        <g:link controller="site" action="create" class="btn btn-large"><r:img dir="images/icons" file="site.png"/> Add a site</g:link>
        <g:link controller="activity" action="create" class="btn btn-large"><r:img dir="images/icons" file="activity.png"/> Add an activity</g:link>
        <g:link controller="assessment" action="create" class="btn btn-large"><r:img dir="images/icons" file="assessment.png"/> Add an assessment</g:link>
    </div>

    <div class="row-fluid ">
        <div class="span7 well well-small map-box">
            <div id="map" style="width: 100%; height: 100%;"></div>
        </div>

        <div class="span5 well list-box">
            <h3 class="pull-left">Projects</h3>
            <span id="project-filter-warning" class="label filter-label label-warning hide pull-left">Filtered</span>
            <div class="control-group pull-right">
                <div class="input-append">
                    <g:textField class="filterinput input-medium" data-target="project"
                                 title="Type a few characters to restrict the list." name="projects"
                                 placeholder="filter"/>
                    <button type="button" class="btn clearFilterBtn"
                            title="clear"><i class="icon-remove"></i></button>
                </div>
            </div>
            <div class="scroll-list" id="projectList">
                <div class="accordion" id="accordion2">
                    <g:each in="${projects}" var="p" status="i">
                        <div class="accordion-group">
                            <div class="accordion-heading">
                                <a class="accordion-toggle projectHighlight" data-id="${p.id}" data-toggle="collapse" data-parent="#accordion2" href="#collapse${i}">
                                    ${p.name}
                                </a>
                            </div>
                            <div id="collapse${i}" class="accordion-body collapse">
                                <div class="accordion-inner projectInfoWindow">
                                    <div>
                                        <i class="icon-home"></i>
                                        <g:link controller="project" action="index" id="${p.projectId}" params="[returnTo:'']">Project Home Page</g:link>
                                    </div>
                                    <div>
                                        <i class="icon-globe"></i>
                                        <a href="#" data-id="${p.id}" class="zoom-in btn btn-mini"><i class="icon-zoom-in"></i> Zoom map in</a>
                                        <a href="#" data-id="${p.id}" class="zoom-out btn btn-mini"><i class="icon-zoom-out"></i> Zoom map out</a>
                                    </div>
                                    <div>
                                        <i class="icon-user"></i> ${p.organisationName}
                                    </div>
                                    <div>
                                        <i class="icon-info-sign"></i> ${p.description}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </g:each>
                </div>
            </div>
        </div><!-- /.span6.well -->
    </div><!-- /.row-fluid -->

    <hr />
    <g:link controller="home" action="advanced">Advanced home page</g:link>
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <!--h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre-->
            <h4>Activities</h4>
            <pre>${activities}</pre>
            <h4>Sites</h4>
            <pre>${sites}</pre>
            <h4>Projects</h4>
            <pre>${projects}</pre>
        </div>
    </div>
    </div>

<r:script>
    $(window).load(function () {

        // bind filters
        $('.filterinput').keyup(function() {
            var a = $(this).val(),
                target = $(this).attr('data-target'),
                $target = $('#' + target + 'List .accordion-group');
            if (a.length > 1) {
                // this finds all links in the list that contain the input,
                // and hide the ones not containing the input while showing the ones that do
                var containing = $target.filter(function () {
                    var regex = new RegExp('\\b' + a, 'i');
                    return regex.test($('a', this).text());
                }).slideDown();
                $target.not(containing).slideUp();
                $('#' + target + '-filter-warning').show();
            } else {
                $('#' + target + '-filter-warning').hide();
                $target.slideDown();
            }
            return false;
        });
        $('.clearFilterBtn').click(function () {
            var $filterInput = $(this).prev(),
                target = $filterInput.attr('data-target');
            $filterInput.val('');
            $('#' + target + '-filter-warning').hide();
            $('#' + target + "List .accordion-group").slideDown();
        });

        // highglight icon on map when project name is clicked
        var prevFeatureId;
        $(".projectHighlight").click(function(el) {
            //console.log("projectHighlight", $(this).data("id"), alaMap.featureIndex);
            var fId = $(this).data("id");
            if (prevFeatureId) alaMap.unAnimateFeatureById(prevFeatureId);
            alaMap.animateFeatureById(fId);
            prevFeatureId = fId;
        });

        // zoom in/out to project points via +/- buttons
        var initCentre, initZoom;
        $("a.zoom-in").click(function(el) {
            if (!initCentre && !initZoom) {
                initCentre = alaMap.map.getCenter();
                initZoom = alaMap.map.getZoom();
            }
            var projectId = $(this).data("id");
            var bounds = alaMap.getExtentByFeatureId(projectId);
            alaMap.map.fitBounds(bounds);
        });
        $("a.zoom-out").click(function(el) {
            alaMap.map.setCenter(initCentre);
            alaMap.map.setZoom(initZoom);
        });


        // asynch loading of state information
        $('#siteList a').each(function (i, site) {
            var id = $(site).data('id');
            $.getJSON("${createLink(controller: 'site', action: 'locationLookup')}/" + id, function (data) {
                if (data.error) {
                    console.log(data.error);
                } else {
                    $(site).append(' (' + initialiseState(data.state) + ')');
                }
            });
        });

        // Set-up data for map
        var features = [];
        var projects = ${projects ?: [:]};
        $.each(projects, function(i,el) {
            //console.log(i, "project: ", el.id, el.name, el.sites);
            var linkPrefix = "${createLink(controller:'project')}/";

            if (el.sites && el.sites.length > 0) {
                $.each(el.sites, function(j, s) {
                    console.log("s", s, j);
                    if (s.location && s.location.length > 0 && s.location[0].data && s.location[0].data.decimalLatitude) {
                        var point = {
                            type: "dot",
                            id: el.id,
                            name: el.name,
                            popup: "<div class='projectInfoWindow'><div><i class='icon-home'></i> <a href='" +
                                    linkPrefix + el.projectId + "'>" + el.name + "</a></div><div><i class='icon-user'></i> " +
                                    el.organisationName + "</div></div>",
                            latitude: s.location[0].data.decimalLatitude,
                            longitude: s.location[0].data.decimalLongitude
                        }
                        features.push(point);
                    }
                });
            }

//            if (el.sites[0] && el.sites[0].location && el.sites[0].location[0].data.decimalLatitude) {
//                //console.log("location.data", el.sites[0].location[0].data);
//                point.latitude = el.sites[0].location[0].data.decimalLatitude;
//                point.longitude = el.sites[0].location[0].data.decimalLongitude;
//                features.push(point);
//            }

        });

        console.log("total points: " + features.length);

        var mapData = {
            "zoomToBounds": true,
            "zoomLimit": 12,
            "highlightOnHover": false,
            "features": features
        }

        //console.log("mapData", mapData);

        init_map_with_features({
                mapContainer: "map",
                zoomToBounds:true,
                scrollwheel: false,
                zoomLimit:16
            },
            mapData
        );
    });

    function initialiseState(state) {
        switch (state) {
            case 'Queensland': return 'QLD'; break;
            case 'Victoria': return 'VIC'; break;
            case 'Tasmania': return 'TAS'; break;
            default:
                var words = state.split(' '), initials = '';
                for(var i=0; i < words.length; i++) {
                    initials += words[i][0]
                }
                return initials;
        }
    }
    /* This implementation of list filtering is not used but is left for reference.
       The jQuery implementation is quicker and cleaner in this case. This may
       not be true if the data model is needed for other purposes.
    var data = {};
    data.sites = /$/{sites};

    function ViewModel (data) {
        var self = this;
        self.sitesFilter = ko.observable("");
        self.sites = ko.observableArray(data.sites);
        self.isSitesFiltered = ko.observable(false);
        // Animation callbacks for the lists
        self.showElement = function(elem) { if (elem.nodeType === 1) $(elem).hide().slideDown() };
        self.hideElement = function(elem) { if (elem.nodeType === 1) $(elem).slideUp(function() { $(elem).remove(); }) };

        self.filteredSites = ko.computed(function () {
            var filter = self.sitesFilter().toLowerCase();
            var regex = new RegExp('\\b' + filter, 'i');
            if (!filter || filter.length === 1) {
                self.isSitesFiltered(false);
                return self.sites();
            } else {
                self.isSitesFiltered(true);
                return ko.utils.arrayFilter(self.sites(), function (item) {
                    return regex.test(item.name);
                })
            }
        });
        self.clearSiteFilter = function () {
            self.sitesFilter("");
        }
    }
    var viewModel = new ViewModel(data);
    ko.applyBindings(viewModel);*/

</r:script>
</body>
</html>