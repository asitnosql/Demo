
xquery version "1.0-ml";

declare option xdmp:mapping "false";

declare function local:module-exists($uri as xs:string) as xs:boolean {
    if (xdmp:modules-database()) then
        xdmp:eval(fn:concat('fn:doc-available("', $uri, '")'), (),
            <options xmlns="xdmp:eval">
                <database>{xdmp:modules-database()}</database>
            </options>
        )
    else
        xdmp:uri-is-file($uri)
};

declare function local:get-controller-uri($controller-name as xs:string) as xs:string {
    fn:concat("/common/controller/", $controller-name,"-controller.xqy")
};

declare function local:get-error-page($resource-uri as xs:string) as xs:string {
    fn:concat("/common/view", $resource-uri)
};

declare function local:get-resource-uri($resource-uri as xs:string) as xs:string {
    fn:concat("/resources", $resource-uri)
};

let $request-url := xdmp:get-request-url()
let $request-path := xdmp:get-request-path()
let $query := if (fn:contains($request-url, "?")) then fn:substring-after($request-url, "?") else ()

(:let $log := xdmp:log(text { "original url:", $request-url}) :)

let $resource-path := local:get-resource-uri($request-path)

let $err-page-path := local:get-error-page($request-path)

let $request-url :=
    (: check if just a resource is being addressed :)
    if (local:module-exists($resource-path)) then
        local:get-resource-uri($request-url)

    else if (fn:ends-with($err-page-path, "/") and local:module-exists(fn:concat($err-page-path, "error.xqy"))) then
        fn:string-join(($err-page-path, "error.xqy", if ($query) then ("?controller=", $query) else ()), '')

    (: bypass for test interface :)
    else if (fn:matches($request-url, "^/test/?")) then
        $request-url
    else if (fn:contains($request-url, "studentInfo")) then
        concat("/demo/student_info.xqy?", substring-after(xdmp:get-request-url(), "?"))

  else (
        (:RESTFUL Controller should have pattern /controller-name/action?params :)
        let $request-paths := fn:tokenize($request-path,"/")
        let $controller-name  := $request-paths[2]
        let $controller-uri := local:get-controller-uri($controller-name)
        let $controller-exists := local:module-exists($controller-uri)
        let $log := xdmp:log(text{"controller:", $controller-uri, " exists: ", $controller-exists}, "debug")
        return
          if ($controller-exists) then
             let $action := $request-paths[3]
             let $new-url :=
                fn:string-join((
                    "/common/controller.xqy?controller=", $controller-name,
                    if ($action) then ("&amp;action=",$action) else (),
                    if ($query) then ("&amp;",$query) else ()
                ),'')
             return $new-url
          else
              fn:string-join((local:get-error-page('/'), "error.xqy?controller=", $controller-name), '')
            (: pce specific calls :)
            (: GJo: would be better to deprecated this?
            let $request-url := fn:replace($request-url, "^/search(.*)$", "/pce-search$1")
            :)
            (:Let all methods just hit main controller
            let $request-url := fn:replace($request-url, "^/([a-zA-Z_\-]+)\?(.*)$", "/common/controller.xqy?action=$1&amp;$2")
            let $request-url := fn:replace($request-url, "^/([a-zA-Z_\-]+)/?$", "/common/controller.xqy?action=$1")
            return
              $request-url
              :)
    )

(: let $log := xdmp:log(text { "final url: ", $request-url}) :)
return
   $request-url
