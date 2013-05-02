/******************************************************************************\
 *  CONFIG MANAGEMENT
 \******************************************************************************/
def appName = 'fieldcapture'
def ENV_NAME = "${appName.toUpperCase()}_CONFIG"
def default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if(System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println "Including configuration file specified in environment: " + System.getenv(ENV_NAME);
    grails.config.locations = ["file:" + System.getenv(ENV_NAME)]
} else if(System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "Including configuration file specified on command line: " + System.getProperty(ENV_NAME);
    grails.config.locations = ["file:" + System.getProperty(ENV_NAME)]
} else if(new File(default_config).exists()) {
    println "Including default configuration file: " + default_config;
    def loc = ["file:" + default_config]
    println ">> loc = " + loc
    grails.config.locations = loc
    println "grails.config.locations = " + grails.config.locations
} else {
    println "No external configuration file defined."
}
println "(*) grails.config.locations = ${grails.config.locations}"

grails.project.groupId = "au.org.ala." + appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [
    all:           '*/*',
    atom:          'application/atom+xml',
    css:           'text/css',
    csv:           'text/csv',
    form:          'application/x-www-form-urlencoded',
    html:          ['text/html','application/xhtml+xml'],
    js:            'text/javascript',
    json:          ['application/json', 'text/json'],
    multipartForm: 'multipart/form-data',
    rss:           'application/rss+xml',
    text:          'text/plain',
    xml:           ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

/******************************************************************************\
 *  EXTERNAL SERVERS
 \******************************************************************************/
if (!biocache.baseURL) {
    biocache.baseURL = "http://biocache.ala.org.au/"
}
if (!spatial.baseURL) {
    spatial.baseURL = "http://spatial.ala.org.au/"
}
if (!ala.baseURL) {
    ala.baseURL = "http://www.ala.org.au"
}
if (!headerAndFooter.baseURL) {
    headerAndFooter.baseURL = "http://www2.ala.org.au/commonui"
}
// spatial services
if (!spatial.wms.url) {
    spatial.wms.url = spatial.baseURL + "geoserver/ALA/wms?"
}
if (!spatial.wms.cache.url) {
    spatial.wms.cache.url = spatial.baseURL + "geoserver/gwc/service/wms?"
}
if (!spatial.layers.service.url) {
    spatial.layers.service.url = spatial.baseURL + "layers-service"
}
if (!sld.polgon.default.url) {
    sld.polgon.default.url = "http://fish.ala.org.au/data/alt-dist.sld"
}
if (!sld.polgon.highlight.url) {
    sld.polgon.highlight.url = "http://fish.ala.org.au/data/fc-highlight.sld"
}

spatialLayerServices.baseUrl = "http://spatial-dev.ala.org.au/ws/"

app.external.model.dir = "/data/${appName}/models/"

environments {
    development {
        grails.logging.jul.usebridge = true
        server.port = "8087"
        grails.app.context = "/"
        grails.host = "http://devt.ala.org.au"
        serverName = "${grails.host}:${server.port}"

        security.cas.appServerName = serverName
        security.cas.contextPath = grails.app.context
        ecodata.baseUrl = 'http://localhost:8080/ecodata/ws/'
    }
    test {
        grails.logging.jul.usebridge = true
        server.port = "8080"
        grails.app.context = "/fieldcapture"
        grails.host = "http://ala-testweb1.ala.org.au"
        serverName = "${grails.host}:${server.port}"

        security.cas.appServerName = serverName
        security.cas.contextPath = "/" + grails.app.context
        ecodata.baseUrl = 'http://localhost:8080/ecodata/ws/'
    }
    nectar {
        grails.logging.jul.usebridge = true
        server.port = "8080"
        grails.app.context = "/fieldcapture"
        grails.host = "http://115.146.94.201"
        serverName = "${grails.host}:${server.port}"

        security.cas.appServerName = serverName
        security.cas.contextPath = "/" + grails.app.context
        ecodata.baseUrl = 'http://115.146.94.201:8080/ecodata/ws/'
    }
    production {
        grails.logging.jul.usebridge = false
        grails.app.context = "/"

        security.cas.appServerName = grails.serverURL
        security.cas.contextPath = ""
        ecodata.baseUrl = 'http://ecodata.ala.org.au/ws/'
    }
}

//println "grails.serverURL is ${grails.serverURL}"

// log4j configuration
log4j = {
    appenders {
        environments{
            development {
                console name: "stdout",
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"),
                        threshold: org.apache.log4j.Level.DEBUG
                rollingFile name: "fieldcaptureLog",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture.log",
                        threshold: org.apache.log4j.Level.INFO,
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
                rollingFile name: "stacktrace",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture-stacktrace.log"
            }
            test {
                rollingFile name: "fieldcaptureLog",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture.log",
                        threshold: org.apache.log4j.Level.INFO,
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
                rollingFile name: "stacktrace",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture-stacktrace.log"
            }
            nectar {
                rollingFile name: "fieldcaptureLog",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture.log",
                        threshold: org.apache.log4j.Level.INFO,
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
                rollingFile name: "stacktrace",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture-stacktrace.log"
            }
            production {
                rollingFile name: "fieldcaptureLog",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture.log",
                        threshold: org.apache.log4j.Level.INFO,
                        layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
                rollingFile name: "stacktrace",
                        maxFileSize: 104857600,
                        file: "/var/log/tomcat6/fieldcapture-stacktrace.log"
            }
        }
    }

    environments {
        development {
            all additivity: false, stdout: [
                    'grails.app.controllers.au.org.ala.fieldcapture',
                    'grails.app.domain.au.org.ala.fieldcapture',
                    'grails.app.services.au.org.ala.fieldcapture',
                    'grails.app.taglib.au.org.ala.fieldcapture',
                    'grails.app.conf.au.org.ala.fieldcapture',
                    'grails.app.filters.au.org.ala.fieldcapture'/*,
                    'au.org.ala.cas.client'*/
            ]
        }
    }

    all additivity: false, fieldcaptureLog: [
            'grails.app.controllers.au.org.ala.fieldcapture',
            'grails.app.domain.au.org.ala.fieldcapture',
            'grails.app.services.au.org.ala.fieldcapture',
            'grails.app.taglib.au.org.ala.fieldcapture',
            'grails.app.conf.au.org.ala.fieldcapture',
            'grails.app.filters.au.org.ala.fieldcapture'
    ]

    debug 'grails.app.controllers.au.org.ala'

    error  'org.codehaus.groovy.grails.web.servlet',        // controllers
           'org.codehaus.groovy.grails.web.pages',          // GSP
           'org.codehaus.groovy.grails.web.sitemesh',       // layouts
           'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
           'org.codehaus.groovy.grails.web.mapping',        // URL mapping
           'org.codehaus.groovy.grails.commons',            // core / classloading
           'org.codehaus.groovy.grails.plugins',            // plugins
           'org.codehaus.groovy.grails.orm.hibernate',      // hibernate integration
           'org.springframework',
           'org.hibernate',
           'net.sf.ehcache.hibernate'
}