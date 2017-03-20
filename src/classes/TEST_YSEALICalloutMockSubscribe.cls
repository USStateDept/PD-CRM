global class TEST_YSEALICalloutMockSubscribe implements HttpCalloutMock {
	global HttpResponse respond( HTTPRequest req )
  	{
        HttpResponse res = new HttpResponse();
        res.setStatus( 'OK' );
        res.setStatusCode( 200 );
        String jsonResp = '{' +
        '"add_count": 1,' +
        '"adds": [' +
            '{' +
                '"email": "ngamocha@gmail.com",' +
                '"euid": "123890709",' +
                '"leid": "d2457bcfca"' +
            '}' +
        '],' +
        '"update_count": 0,' +
        '"error_count": 1,' +
        '"errors": [' +
            '{' +
                '"email": {' +
                    '"email": "c@gmail.com",' +
                    '"euid": "349879012",' +
                    '"leid": "d2457bcfca"' +
                '},' +
                '"code": 215,' +
                '"error": "this email is already subscribed to list"' +
            '}' +
        ']' +
    '}';
        res.setBody(jsonResp);
        return res;
  	}
    
}