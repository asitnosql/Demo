xquery version "1.0-ml";
import module namespace custom-function="http://demo.com/custom-function" at "custom-function.xqy";

declare namespace html = "http://www.w3.org/1999/xhtml";


xdmp:set-response-content-type("text/html")
,


<html>
	<head>
		Students Details :
	</head>
	<body>
		<table height="50%" width="50%" border="1">
		<th>Student Name</th><th>Father Nam</th><th>Gender</th><th>DOB</th>
		  {
			let $studentId := xdmp:get-request-field("id")
			for $eachStudent in custom-function:get-student-details($studentId)
			return 
			(
			<tr>
			 <td>{$eachStudent/student/name/text()}</td>
			 <td>{$eachStudent/student/f_name/text()}</td>
			 <td>{$eachStudent/student/gender/text()}</td>
			 <td>{$eachStudent/student/dob/text()}</td>
			</tr>
			)
		 }
		</table>
	</body>
</html>