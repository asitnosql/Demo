xquery version "1.0-ml";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";


let $studentId := xdmp:get-request-field("id")
let $outputFormat := xdmp:get-request-field("format")


let $studenInfo := cts:search(fn:doc(),
							  cts:element-attribute-value-query(
								xs:QName("student"), xs:QName("id"),$studentId)
							 ) 
	  
let $studentMark := cts:search(fn:doc(),
							   cts:element-attribute-value-query(
								xs:QName("student_result"), xs:QName("id"),$studentId)
						) 
let $result :=    element student_com_info {
                                  attribute id {$studentId}  ,
                                  element name {$studenInfo/student/name/text()},
                                  element f_name {$studenInfo/student/f_name/text()},
                                  element result {$studentMark/student_result/* }
                                 } 
				
return 
		if($outputFormat="json") then (: result in json format :)
        (		
			let $custom-config :=
				let $config := json:config("custom")
				return (map:put($config, "array-element-names",(xs:QName("student"))), 
						map:put($config, "whitespace","ignore"),
						map:put($config, "text-value","value"),
						$config) 
			return
			(
			  json:transform-to-json($result, $custom-config)
			)
		)
		else (: result in xml format :)
		(
			$result
		)
   