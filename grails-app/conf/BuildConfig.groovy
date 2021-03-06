grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.6
grails.project.source.level = 1.6
//grails.project.war.file = "target/${appName}-${appVersion}.war"
grails.project.fork.run=false
//grails.server.port.http = 8079

// uncomment (and adjust settings) to fork the JVM to isolate classpaths
//grails.project.fork = [
//   run: [maxMemory:1024, minMemory:64, debug:false, maxPerm:256]
//]

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // specify dependency exclusions here; for example, uncomment this to disable ehcache:
        // excludes 'ehcache'
        excludes 'xercesImpl'

    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve
    legacyResolve true // whether to do a secondary resolve on plugin installation, not advised and here for backwards compatibility

    repositories {
        inherits true // Whether to inherit repository definitions from plugins

        grailsPlugins()
        grailsHome()
        grailsCentral()

        mavenLocal()
        mavenCentral()

        // uncomment these (or add new ones) to enable remote dependency resolution from public Maven repositories
        //mavenRepo "http://snapshots.repository.codehaus.org"
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"
		mavenRepo "http://mvnrepository.com"
	mavenRepo "http://ala-wonder.it.csiro.au/nexus/content/repositories/releases/"
        mavenRepo "http://maven.ala.org.au/repository"
        mavenRepo "http://oss.sonatype.org/content/repositories/releases/"
        mavenRepo "http://download.osgeo.org/webdav/geotools/"
    }

    def seleniumVersion = "2.21.0"
    def geoToolsVersion = "11.2"
    def imgscalrVersion = "4.2"
    dependencies {
    	compile ([group:'javax.media', name:'jai-core', version:'1.1.3'])
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes e.g.

        // runtime 'mysql:mysql-connector-java:5.1.22'
        test "org.gebish:geb-spock:0.9.0"
        test("org.seleniumhq.selenium:selenium-htmlunit-driver:$seleniumVersion") {
            exclude "xml-apis"
        }
        test("org.seleniumhq.selenium:selenium-chrome-driver:$seleniumVersion")
        test("org.seleniumhq.selenium:selenium-firefox-driver:$seleniumVersion")
        test "org.spockframework:spock-grails-support:0.7-groovy-2.0"

        // ElasticSearch
        compile "org.elasticsearch:elasticsearch:1.1.2"

        // Schema validation for external web service clients
        compile "com.github.fge:json-schema-validator:2.1.6"
		compile "com.itextpdf:itextpdf:5.5.1"
        compile "org.apache.httpcomponents:httpmime:4.1.2"

        compile "org.geotools.xsd:gt-xsd-kml:${geoToolsVersion}"
        compile "org.geotools:gt-shapefile:${geoToolsVersion}"
        compile "org.geotools:gt-geojson:${geoToolsVersion}"
        compile "org.geotools:gt-epsg-hsql:${geoToolsVersion}"

        compile "org.imgscalr:imgscalr-lib:${imgscalrVersion}"

    }

    plugins {
        runtime ":jquery:1.8.3"
        runtime ":resources:1.1.6"
        runtime ":csv:0.3.1"
        runtime ":ala-web-theme:0.2.2"

        // Uncomment these (or add new ones) to enable additional resources capabilities
        //runtime ":zipped-resources:1.0"
        //runtime ":cached-resources:1.0"
        //runtime ":yui-minify-resources:0.1.5"

        compile ":mongodb:1.3.0"
        compile ":quartz:1.0.2"
        compile ":excel-export:0.2.0"
        compile ":excel-import:1.0.0"

        build ":tomcat:$grailsVersion"

        compile ':cache:1.0.1'

        test ":geb:0.9.0"
        test(":spock:0.7") {
            exclude "spock-grails-support"
        }


        build ':release:2.2.1', ':rest-client-builder:1.0.3', {
            export = false
        }

    }
}
