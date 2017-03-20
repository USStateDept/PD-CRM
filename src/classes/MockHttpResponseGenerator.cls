@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://api.createsend.com/api/v3.1/lists/test/active.json?page=1&amp;amp;pagesize=1000&amp;amp;orderfield=date&amp;amp;orderdirection=asc', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        
        
        SubscriberResponse.CustomFields cus= new SubscriberResponse.CustomFields();
		cus.Key='[SalesforceLeadId]';
		cus.Value='test';
		List<SubscriberResponse.CustomFields> lstcus = new List<SubscriberResponse.CustomFields>();
        lstcus.add(cus);
        
		SubscriberResponse.Results res=new SubscriberResponse.Results();
		res.EmailAddress='test@test.com';
		res.Name='namer';
		res.Date1='test';
		res.State='test';
		res.ReadsEmailWith='test'; 
		res.CustomFields=lstcus;
		List<SubscriberResponse.Results> lstres = new List<SubscriberResponse.Results>();
        lstres.add(res);
        
        
		SubscriberResponse ar=new SubscriberResponse();
		ar.Results=lstres;	
		ar.ResultsOrderedBy = 'test';
		ar.OrderDirection = 'test';
		ar.PageNumber = 123;
		ar.PageSize = 123;
		ar.RecordsOnThisPage = 123;
		ar.TotalNumberOfRecords = 123;
		ar.NumberOfPages = 123;
        String strJ = (String)JSON.serialize(ar);
        
        // Create a fake response
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody(strJ);
        res1.setStatusCode(200);
        return res1;
    }
}