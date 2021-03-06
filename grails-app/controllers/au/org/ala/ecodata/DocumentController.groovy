package au.org.ala.ecodata

import grails.converters.JSON

class DocumentController {

    def documentService

    static allowedMethods = [save: "POST", update: "POST", delete: "DELETE"]

    // JSON response is returned as the unconverted model with the appropriate
    // content-type. The JSON conversion is handled in the filter. This allows
    // for universal JSONP support.
    def asJson = { model ->
        response.setContentType("application/json; charset=\"UTF-8\"")
        model
    }

    def index() {
        log.debug "Total documents = ${Document.count()}"
        render "${Document.count()} documents"
    }

    def get(String id) {
        def detail = []
        if (!id) {
            def list = documentService.getAll(params.includeDeleted as boolean, params.view)
            list.sort {it.name}
            //log.debug list
            asJson([list: list])
        } else {
            def doc = documentService.get(id, detail)
            if (doc) {
                asJson doc
            } else {
                render status:404, text: 'No such id'
            }
        }
    }

    def find(String entity, String id) {
        def result = documentService.findAllByOwner(entity+'Id', id)
        asJson([documents:result])
    }

    @RequireApiKey
    def delete(String id) {
        def a = Document.findByDocumentId(id)
        if (a) {
            if (params.destroy) {
                documentService.deleteFile(a)
                a.delete()

            } else {
                a.status = 'deleted'
                a.save(flush: true)
            }
            render (status: 200, text: 'deleted')
        } else {
            response.status = 404
            render status:404, text: 'No such id'
        }
    }

    /**
     * Creates or updates a Document object via an HTTP multipart request.
     * This method currently expects:
     * 1) For an update, the document ID should be in the URL path.
     * 2) The document metadata is supplied (JSON encoded) as the value of the
     * "document" HTTP parameter.  To create a text file from a supplied string, supply the filename and content
     * as JSON properties.
     * 3) The file contents to be supplied as the value of the "files" HTTP parameter.  This is optional for
     * an update.
     * @param id The ID of an existing document to update.  If not present, a new Document will be created.
     */
    @RequireApiKey
    def update(String id) {
        def props, file = null
        def stream = null
        if (request.respondsTo('getFile')) {
            file = request.getFile('files')
            props = JSON.parse(params.document)
            if (!props.contentType && file) {
               props.contentType = file.contentType
            }
            stream = file?.inputStream
        }
        else {
            props = request.JSON
            if (props.content) {
                stream = new StringReader(props.content)
                props.remove('content')
            }
        }
        def result
        def message

        if (id) {
            result = documentService.update(props,id, stream)
            message = [message: 'updated', documentId: result.documentId, url:result.url]
        } else {
            result = documentService.create(props, stream)
            message = [message: 'created', documentId: result.documentId, url:result.url]
        }
        if (result.status == 'ok') {
            response.status = 200
            render message as JSON
        } else {
            //Document.withSession { session -> session.clear() }
            log.error result.error
            render status:400, text: result.error
        }
    }

    /**
     * Serves up a file named by the supplied filename HTTP parameter.  It is mostly as a convenience for development
     * as the files will be served by Apache in prod.
     */
    def download() {

        if (!params.filename) {
            response.status = 400
            return null
        }

        File file = new File(documentService.fullPath('', params.filename))

        if (!file.exists()) {
            response.status = 404
            return null
        }

        // Probably should store the mime type in the document, however in prod the files will be served up by
        // Apache so this doesn't have to be perfect.
        def contentType = URLConnection.guessContentTypeFromName(file.name)
        response.setContentType(contentType?:'application/octet-stream')
        response.outputStream << new FileInputStream(file)
        response.outputStream.flush()

        return null
    }

}
