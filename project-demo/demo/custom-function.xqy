xquery version "1.0-ml";
module namespace custom-function = "http://demo.com/custom-function";

declare function custom-function:get-student-details($studentId)
{
   if($studentId) then
				(
				cts:search(fn:doc(),
							cts:element-attribute-value-query(
							xs:QName("student"), xs:QName("id"),$studentId)
							) 
				)
				else 
				(
					cts:search(fn:doc(), cts:collection-query("Student"))
				)

};

